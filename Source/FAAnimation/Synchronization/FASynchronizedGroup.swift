//
//  FASynchronizedGroup.swift
//  FlightAnimator
//
//  Created by Anton on 8/13/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

func ==(lhs:FASynchronizedGroup, rhs:FASynchronizedGroup) -> Bool {
    return lhs.weakLayer == rhs.weakLayer &&
        lhs.animationKey == rhs.animationKey
}

public class FASynchronizedGroup : CAAnimationGroup {
    
    internal var animationKey : String?
    
    internal var _primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    
    internal weak var weakLayer : CALayer? {
        didSet {
            if let currentAnimations = animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FABasicAnimation {
                        customAnimation.weakLayer = weakLayer
                    }
                }
            }
            
            startTime = weakLayer?.convertTime(CACurrentMediaTime(), fromLayer: nil)
        }
    }
    
    
    // The start time of the animation, set by the current time of
    // the layer when it is added. Used by the springs to find the
    // current velocity in motion
    internal var startTime : CFTimeInterval? {
        didSet {
            if let currentAnimations = animations {
                for animation in currentAnimations {
                    if let customAnimation = animation as? FABasicAnimation {
                        customAnimation.startTime = startTime
                    }
                }
            }
        }
    }
    
    // This is used to
    internal var primaryEasingFunction : FAEasing = FAEasing.Linear
    internal weak var primaryAnimation : FABasicAnimation?
    internal var displayLink : CADisplayLink?
    
    public var _segmentArray = [AnimationTrigger]()
    internal var segmentArray = [AnimationTrigger]()
    
    override init() {
        super.init()
        animations = [CAAnimation]()
        fillMode = kCAFillModeForwards
        removedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animationGroup = super.copyWithZone(zone) as! FASynchronizedGroup
        animationGroup.weakLayer                = weakLayer
        animationGroup.startTime                = startTime
        animationGroup.animationKey             = animationKey
        animationGroup._segmentArray            = _segmentArray
        animationGroup.segmentArray             = segmentArray
        animationGroup.primaryAnimation         = primaryAnimation
        animationGroup._primaryTimingPriority    = _primaryTimingPriority
        return animationGroup
    }
    
    final public func configureAnimationGroup(withLayer layer: CALayer?, animationKey key: String?) {
        animationKey = key
        weakLayer = layer
    }
    
    final public func synchronizeAnimationGroup(withLayer layer: CALayer, animationKey key: String?) {

        configureAnimationGroup(withLayer: layer, animationKey: key)

        if let keys = weakLayer?.animationKeys() {
            for key in Array(Set(keys)) {
                if let oldAnimation = weakLayer?.animationForKey(key) as? FAAnimationGroup {
                    oldAnimation.stopTriggerTimer()
                    synchronizeAnimations(oldAnimation)
                }
            }
        } else {
            synchronizeAnimations(nil)
        }
    }
}

//MARK: - Animation Synchronization

internal extension FASynchronizedGroup {
    
    func synchronizeAnimations(oldAnimationGroup : FAAnimationGroup?) {
        
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
                let oldAnimation : FABasicAnimation? = oldAnimations[key]
                
                newPrimaryAnimation.synchronize(runningAnimation: oldAnimation)
                
                durationArray.append(newPrimaryAnimation.duration)
                newAnimations[key] = newPrimaryAnimation
            }
        }
        
        animations = newAnimations.map {$1}
        updateGroupDurationBasedOnTimePriority(durationArray)
    }
    
    
    func updateGroupDurationBasedOnTimePriority(durationArray: Array<CFTimeInterval>) {
        
        switch _primaryTimingPriority {
        case .MaxTime:
            duration = durationArray.maxElement()!
        case .MinTime:
            duration = durationArray.minElement()!
        case .Median:
            duration = durationArray.sort(<)[durationArray.count / 2]
        case .Average:
            duration = durationArray.reduce(0, combine: +) / Double(durationArray.count)
        }
        
        let filteredAnimation = animations!.filter({ $0.duration == duration })
        
        if let primaryDrivingAnimation = filteredAnimation.first as? FABasicAnimation {
            primaryAnimation = primaryDrivingAnimation
        }
        
        guard animations != nil else {
            return
        }
        
        var newAnimationsArray = [FABasicAnimation]()
        newAnimationsArray.append(filteredAnimation.first! as! FABasicAnimation)
        
        let filteredNonAnimation = animations!.filter({ $0 != primaryAnimation })
        
        for animation in filteredNonAnimation {
            animation.duration = duration
            
            if let customAnimation = animation as? FABasicAnimation {
                
                if customAnimation.easingFunction.isSpring() == false {
                    customAnimation.synchronize()
                }
                
                newAnimationsArray.append(customAnimation)
            }
        }
    }
    
    func animationDictionaryForGroup(animationGroup : FASynchronizedGroup?) -> [String : FABasicAnimation] {
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

public func ==(lhs:AnimationTrigger, rhs:AnimationTrigger) -> Bool {
    return lhs.animatedView == rhs.animatedView &&
        lhs.isTimedBased == rhs.isTimedBased &&
        lhs.triggerProgessValue == rhs.triggerProgessValue &&
        lhs.animationKey == rhs.animationKey
}

public class AnimationTrigger : Equatable {
    public  var isTimedBased = true
    public var triggerProgessValue : CGFloat?
    public var animationKey : NSString?
    public weak var animatedView : UIView?
    public weak var animation : FAAnimationGroup?
    
    required public init() {
    
    }

}

public extension FASynchronizedGroup {
    
    func attachTrigger(animation : AnyObject,
                       onView view : UIView,
                       atTimeProgress timeProgress: CGFloat? = 0.0,
                       atValueProgress valueProgress: CGFloat? = nil) {
        
        var progress : CGFloat = timeProgress ?? 0.0
        var timeBased : Bool = true
        
        if valueProgress != nil {
            progress = valueProgress!
            timeBased = false
        }
        
        var animationGroup : FAAnimationGroup?
        
        if let group = animation as? FAAnimationGroup {
            animationGroup = group
        } else if let animation = animation as? FABasicAnimation {
            animationGroup = FAAnimationGroup()
            animationGroup!.animations = [animation]
        }
    
        guard animationGroup != nil else {
            return
        }
    
        animationGroup?.animationKey = String(NSUUID().UUIDString)
        animationGroup?.weakLayer = view.layer
        
        let animationTrigger = AnimationTrigger()
        animationTrigger.isTimedBased = timeBased
        animationTrigger.triggerProgessValue = progress
        animationTrigger.animationKey = animationGroup?.animationKey
        animationTrigger.animatedView = view
        
        _segmentArray.append(animationTrigger)
        view.appendAnimation(animationGroup!, forKey: animationGroup!.animationKey!)
    }
    
    func startTriggerTimer() {
        
        guard displayLink == nil && _segmentArray.count > 0 else {
            return
        }
        
        stopTriggerTimer()
        segmentArray = _segmentArray
        
        displayLink = CADisplayLink(target: self, selector: #selector(FAAnimationGroup.updateTrigger))
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink!.paused = false
        
        //print("START ++++++++ CALINK \(weakLayer?.description)  - \(displayLink)\n")
    }
    
    func updateTrigger() {
        
        for segment in segmentArray {
            if segment.isTimedBased && primaryAnimation?.timeProgress() >= segment.triggerProgessValue ||
                !segment.isTimedBased && primaryAnimation?.valueProgress() >= segment.triggerProgessValue  {
                
                segmentArray.removeObject(segment)
                segment.animatedView!.applyAnimation(forKey: segment.animationKey! as String)
                
                //print("TRIGGER  ++++++++ CALINK \(weakLayer?.description)  - \(displayLink)\n")
            }
            
            if segmentArray.count <= 0 {
                stopTriggerTimer()
                return
            }
        }
    }
    
    func stopTriggerTimer() {
        
        guard displayLink != nil else {
            return
        }
        
        self.displayLink?.paused = true
        
        // print("STOP ++++++++ CALINK \(weakLayer?.description)  - \(displayLink)\n")
        segmentArray = [AnimationTrigger]()
        
        self.displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        self.displayLink = nil
    }
}