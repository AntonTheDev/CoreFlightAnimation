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

public class FAAnimationGroup : CAAnimationGroup {
       
    public var animationUUID : String?
    
    public weak var animatingLayer : CALayer? { didSet { synchronizeSubAnimationLayers() }}
    internal var startTime : CFTimeInterval?  { didSet { synchronizeSubAnimationStartTime() }}
    
    public var timingPriority : FAPrimaryTimingPriority = .MaxTime
    
    internal weak var primaryAnimation : FABasicAnimation?
    
    override public init() {
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
        
        animationGroup.animationUUID           = animationUUID
        animationGroup.animatingLayer          = animatingLayer
      
        animationGroup.primaryAnimation        = primaryAnimation
        animationGroup.startTime               = startTime
        animationGroup.timingPriority          = timingPriority
    
        return animationGroup
    }
    
    final internal func synchronizeAnimationGroup(withLayer layer: CALayer, forKey key: String?) {
        
        animationUUID = key
        animatingLayer = layer
      
        if let keys = animatingLayer?.animationKeys() {
            for key in Array(Set(keys)) {
                
                if let oldAnimation = animatingLayer?.animationForKey(key) as? FASequenceAnimationGroup {
                    oldAnimation.sequenceDelegate?.stopSequence()
                    synchronizeAnimations(oldAnimation)
                }
                
                if let oldAnimation = animatingLayer?.animationForKey(key) as? FAAnimationGroup {
                    synchronizeAnimations(oldAnimation)
                }
            }
        } else {
            synchronizeAnimations(nil)
        }
    }
}


//MARK: - Synchronization Logic

internal extension FAAnimationGroup {
    
    /**
     Synchronizes the calling animation group with the passed animation group
     
     - parameter oldAnimationGroup: old animation in flight
     */
    internal func synchronizeAnimations(oldAnimationGroup : FAAnimationGroup?) {
        
        var durationArray =  [Double]()
        
        var oldAnimations = animationDictionaryForGroup(oldAnimationGroup)
        var newAnimations = animationDictionaryForGroup(self)
        
        // Find all Primary Animations
        let filteredPrimaryAnimations = newAnimations.filter({ $0.1.isPrimary == true })
        let filteredNonPrimaryAnimations = newAnimations.filter({ $0.1.isPrimary == false })
        
        var primaryAnimations = [String : FABasicAnimation]()
        var nonPrimaryAnimations = [String : FABasicAnimation]()
        
        for result in filteredPrimaryAnimations {
            primaryAnimations[result.0] = result.1
        }
        
        for result in filteredNonPrimaryAnimations {
            nonPrimaryAnimations[result.0] = result.1
        }
        
        //If no animation is primary, all animations become primary
        if primaryAnimations.count == 0 {
            primaryAnimations = newAnimations
            nonPrimaryAnimations = [String : FABasicAnimation]()
        }
        
        for key in primaryAnimations.keys {
            
            if  let newPrimaryAnimation = primaryAnimations[key] {
                
                if let oldAnimation : FABasicAnimation? = oldAnimations[key] {
                    newPrimaryAnimation.synchronize(relativeTo: oldAnimation)
                } else {
                    newPrimaryAnimation.synchronize(relativeTo: nil)
                }
            
                durationArray.append(newPrimaryAnimation.duration)
                newAnimations[key] = newPrimaryAnimation
            }
        }
        
        switch timingPriority {
        case .MaxTime:
            duration = durationArray.maxElement()!
        case .MinTime:
            duration = durationArray.minElement()!
        case .Median:
            duration = durationArray.sort(<)[durationArray.count / 2]
        case .Average:
            duration = durationArray.reduce(0, combine: +) / Double(durationArray.count)
        }
        
        let filteredAnimation = animations!.filter({
            $0.duration == duration    ||
                timingPriority == .Average ||
                timingPriority == .Median
        })
        
        if let primaryDrivingAnimation = filteredAnimation.first as? FABasicAnimation {
            primaryAnimation = primaryDrivingAnimation
        }

        for key in nonPrimaryAnimations.keys {
            
            if let newNonPrimaryAnimation = nonPrimaryAnimations[key] {
                
                newNonPrimaryAnimation.duration = duration
                
                if let oldAnimation : FABasicAnimation? = oldAnimations[key] {
                    newNonPrimaryAnimation.synchronize(relativeTo: oldAnimation)
                } else {
                    newNonPrimaryAnimation.synchronize(relativeTo: nil)
                }
                
                newAnimations[key] = newNonPrimaryAnimation
            }
        }
        
        for key in primaryAnimations.keys {
            
            if  let newPrimaryAnimation = primaryAnimations[key] {
                if newPrimaryAnimation != primaryAnimation {
                    newPrimaryAnimation.duration = duration
                    newPrimaryAnimation.synchronize()
                    newAnimations[key] = newPrimaryAnimation
                }
            }
        }
        
        animations = newAnimations.map {$1}
    }
}

internal extension FAAnimationGroup {
    
    /**
     Called by the didSet observer of the animatingLayer, ensures
     that all the sub animations have their layer set for synchronization
     */
    func synchronizeSubAnimationLayers() {
        if let currentAnimations = animations {
            for animation in currentAnimations {
                if let customAnimation = animation as? FABasicAnimation {
                    customAnimation.animatingLayer = animatingLayer
                }
            }
        }
    }
    
    /**
     Called by the didSet observer of the startTime, ensures
     that all the sub animations have a synchromous startTime
     for calculating progress
     */
    func synchronizeSubAnimationStartTime() {
        if let currentAnimations = animations {
            for animation in currentAnimations {
                if let customAnimation = animation as? FABasicAnimation {
                    customAnimation.startTime = startTime
                }
            }
        }
    }
    
    /**
     Returns a dictionary format of the animations in the FAAnimationGroup.
     The keypath of the animation is used as the key
     
     i.e [keyPath : FABasicAnimation]
     
     - parameter animationGroup: The animation group to transform
     
     - returns: [keyPath : FABasicAnimation] representation of hte animations array
     */
    func animationDictionaryForGroup(animationGroup : FAAnimationGroup?) -> [String : FABasicAnimation] {
        
        var animationDictionary = [String: FABasicAnimation]()
        
        if let group = animationGroup {
            if let currentAnimations = group.animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FABasicAnimation {
                        animationDictionary[customAnimation.keyPath!] = customAnimation
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
        
        if let animation = animatingLayer?.animationForKey(animationUUID!) as? FAAnimationGroup{
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




/**
 Attaches the specified animation, on the specified view, and relative
 the progress value type defined in the method call
 
 Ommit both timeProgress and valueProgress, to trigger the animation specified
 at the start of the calling animation group
 
 Ommit timeProgress, to trigger the animation specified
 at the relative time progress of the calling animation group
 
 Ommit valueProgress, to trigger the animation specified
 at the relative value progress of the calling animation group
 
 If both valueProgres, and timeProgress values are defined,
 it will trigger the animation specified at the relative time
 progress of the calling animation group
 
 - parameter animation:     the animation or animation group to attach
 - parameter view:          the view to attach it to
 - parameter timeProgress:  the relative time progress to trigger animation on the view
 - parameter valueProgress: the relative value progress to trigger animation on the view
 */
/*
 
 public func triggerAnimation(animation : AnyObject,
 onView view : UIView,
 atTimeProgress timeProgress: CGFloat? = nil,
 atValueProgress valueProgress: CGFloat? = nil) {
 
 configureAnimationTrigger(animation,
 onView : view,
 atTimeProgress : timeProgress,
 atValueProgress : valueProgress)
 }
 */
