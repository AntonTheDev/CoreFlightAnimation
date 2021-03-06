//
//  FAAnimationGroup.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

/**
 Equatable FAAnimationGroup Implementation
 */

func ==(lhs:FAAnimationGroup, rhs:FAAnimationGroup) -> Bool {
    return lhs.animatingLayer == rhs.animatingLayer &&
        lhs.animationUUID == rhs.animationUUID
}

/**
 Timing Priority to apply during synchronisation of hte animations
 within the calling animationGroup.
 
 The more property animations within a group, the more likely some
 animations will need more control over the synchronization of
 the timing over others.
 
 There are 4 timing priorities to choose from:
 
 .MaxTime, .MinTime, .Median, and .Average
 
 By default .MaxTime is applied, so lets assume we have 4 animations:
 
 1. bounds
 2. position
 3. alpha
 4. transform
 
 FABasicAnimation(s) are not defined as primary by default,
 synchronization will figure out the relative progress for each
 property animation within the group in flight, then adjust the
 timing based on the remaining progress to the final destination
 of the new animation being applied.
 
 Then based on .MaxTime, it will pick the longest duration form
 all the synchronized property animations, and resynchronize the
 others with a new duration, and apply it to the group itself.
 
 If the isPrimary flag is set on the bounds and position
 animations, it will only include those two animation in
 figuring out the the duration.
 
 Use .MinTime, to select the longest duration in the group
 Use .MinTime, to select the shortest duration in the group
 Use .Median,  to select the median duration in the group
 Use .Average, to select the average duration in the group

 - MaxTime: find the longest duration, and adjust all animations to match
 - MinTime: find the shortest duration and adjust all animations to match
 - Median:  find the median duration, and adjust all animations to match
 - Average: find the average duration, and adjust all animations to match
 */

public enum FAPrimaryTimingPriority : Int {
    case MaxTime
    case MinTime
    case Median
    case Average
}

//MARK: - FAAnimationGroup

public class FAAnimationGroup : FASequenceAnimationGroup {
       
    public var timingPriority : FAPrimaryTimingPriority = .MaxTime

    required public init() {
        super.init()
        animations = [CAAnimation]()
        fillMode = kCAFillModeForwards
        removedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animationGroup = super.copyWithZone(zone) as! FAAnimationGroup
        
        animationGroup.primaryAnimation        = primaryAnimation
        animationGroup.startTime =   startTime
        animationGroup.timingPriority          = timingPriority
    
        return animationGroup
    }
    
    internal func synchronizeAnimationGroup(withLayer layer: CALayer, forKey key: String?) {
       
        
        animationUUID = key
        animatingLayer = layer
      
        if let keys = animatingLayer?.animationKeys() {
            for key in Array(Set(keys)) {
                
                if let oldAnimation = animatingLayer?.animationForKey(key) as? FAAnimationGroup {
                    oldAnimation.sequenceDelegate?.stopSequence()
                    synchronizeAnimations(oldAnimation)
                }
            }
        } else {
            synchronizeAnimations(nil)
        }
        
        
        var reverseAnimationArray = [FABasicAnimation]()
        
        if let animations = animations {
            for animation in animations {
                if let customAnimation = animation as? FABasicAnimation,
                    let reverseAnimation = customAnimation.reverseAnimation  as? FABasicAnimation {
                    
                    if autoreverseInvertEasing {
                        reverseAnimation.easingFunction = reverseAnimation.easingFunction.autoreverseEasing()
                    }
                    
                    reverseAnimationArray.append(reverseAnimation)
                }
            }
        }
        
        let animationGroup = self.sequenceCopy() as! FAAnimationGroup
        animationGroup.animationUUID                = animationUUID! + "REVERSE"
        animationGroup.animations                   = reverseAnimationArray
        animationGroup.progessValue                 = autoreverseInvertProgress ? (1.0 - progessValue) : progessValue
        
        animationGroup.autoreverse                  = autoreverse
        animationGroup.autoreverseCount             = autoreverseCount
        animationGroup.autoreverseDelay             = autoreverseDelay
        animationGroup.autoreverseInvertEasing      = autoreverseInvertEasing
        animationGroup.autoreverseInvertProgress    = autoreverseInvertProgress
        
        animationGroup.reverseAnimation             = self
        
        reverseAnimation = animationGroup
    }
}


//MARK: - Synchronization Logic

internal extension FAAnimationGroup {
    
    internal func synchronizeAnimations(oldAnimationGroup : FAAnimationGroup?) {
        
        var oldAnimations = animationDictionaryForGroup(oldAnimationGroup)
        var newAnimations = animationDictionaryForGroup(self)
        
        for key in newAnimations.keys {
            
            newAnimations[key]!.animatingLayer = animatingLayer
            
            if let oldAnimation = oldAnimations[key] {
                newAnimations[key]!.synchronize(relativeTo: oldAnimation)
            } else {
                newAnimations[key]!.synchronize(relativeTo: nil)
            }
        }
        
        var primaryAnimations = newAnimations.filter({ $0.1.isPrimary == true })
        let hasPrimaryAnimations : Bool = (primaryAnimations.count > 0)
       
        if hasPrimaryAnimations == false {
            primaryAnimations = newAnimations.filter({ $0.1 != nil })
        }
        
        let durationsArray = primaryAnimations.map({ $0.1.duration})

        switch timingPriority {
        case .MaxTime:
            duration = durationsArray.maxElement()!
        case .MinTime:
            duration = durationsArray.minElement()!
        case .Median:
            duration = durationsArray.sort(<)[durationsArray.count / 2]
        case .Average:
            duration = durationsArray.reduce(0, combine: +) / Double(durationsArray.count)
        }
        
        let nonSynchronizedAnimations = newAnimations.filter({ $0.1.duration != duration })
        
        if hasPrimaryAnimations {
            primaryAnimation = (primaryAnimations.filter({ $0.1.duration == duration})).first?.1
        } else {
            primaryAnimation = (newAnimations.filter({ $0.1.duration == duration})).first?.1
        }
    
        for animation in nonSynchronizedAnimations {
            if animation.1.keyPath != primaryAnimation?.keyPath &&
               animation.1.duration > primaryAnimation?.duration {
                
                
                newAnimations[animation.1.keyPath!]!.duration = duration
                newAnimations[animation.1.keyPath!]!.synchronize()
            }
        }
        
        animations = newAnimations.map {$1}
    }
    


}

internal extension FAAnimationGroup {
    
    
    /**
     Returns a dictionary format of the animations in the FAAnimationGroup.
     The keypath of the animation is used as the key
     
     i.e [keyPath : FABasicAnimation]
     
     - parameter animationGroup: The animation group to transform
     
     - returns: [keyPath : FABasicAnimation] representation of hte animations array
     */
    func animationDictionaryForGroup(animationGroup : FAAnimationGroup?, primary : Bool = false) -> [String : FABasicAnimation] {
        
        var animationDictionary = [String: FABasicAnimation]()
        
        if let group = animationGroup {
            if let currentAnimations = group.animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FABasicAnimation {
                        
                        if primary {
                            if customAnimation.isPrimary {
                                animationDictionary[customAnimation.keyPath!] = customAnimation
                            }
                        } else {
                            animationDictionary[customAnimation.keyPath!] = customAnimation
                        }
                    }
                }
            }
        }
        
        return animationDictionary
    }
}


//MARK: - Animation Progress Values

internal extension FAAnimationGroup {
    
    func valueProgress() -> CGFloat {
    
        if let animation = animatingLayer?.animationForKey(animationUUID!) as? FAAnimationGroup{
            return animation.primaryAnimation!.valueProgress()
        }
        
        guard let primaryAnimation = primaryAnimation else {
            print("Primary Animation Nil")
            return 0.0
        }
        
        return primaryAnimation.valueProgress()
    }
    
    func timeProgress() -> CGFloat {
        
        if let animation = animatingLayer?.presentationLayer()?.animationForKey(animationUUID!) as? FAAnimationGroup {
            return animation.primaryAnimation!.timeProgress()
        }
        
        guard let primaryAnimation = primaryAnimation else {
            print("Primary Animation Nil")
            return 0.0
        }
        
        return primaryAnimation.timeProgress()
    }
    
    
    /**
     Not Ready for Prime Time, being declared as private
     
     Adjusts animation based on the progress form 0 - 1
     
     - parameter progress: scrub "to progress" value
     
     private func scrubToProgress(progress : CGFloat) {
     animatingLayer?.speed = 0.0
     animatingLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
     }
     */
}   