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
    return lhs.weakLayer == rhs.weakLayer &&
        lhs.animationKey == rhs.animationKey
}


/**
 The timing priority effects how the time is resynchronized
 across the animation group.
 
 - MaxTime: longest  duration in the synchronized group
 - MinTime: shortest duration in the synchronized group
 - Median:  median   duration in the synchronized group
 - Average: average  duration in the synchronized group
 */
public enum FAPrimaryTimingPriority : Int {
    case MaxTime
    case MinTime
    case Median
    case Average
}

//MARK: - FAAnimationGroup

public class FAAnimationGroup : FASynchronizedGroup {
    
    override public init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
     
     */
    public var timingPriority : FAPrimaryTimingPriority  {
        get { return _timingPriority }
        set { _timingPriority = newValue }
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
    
    /**
     Apply the animation's final state, animated by default but can ve disabled if needed
     
     This method runs through the animations within the current group and applies
     the final values to the underlying layer.
     
     - parameter animated: disables animation, defauls to true
     */
    public func applyFinalState(animated : Bool = false) {
        
        if let animationLayer = weakLayer {
            if animated {
                animationLayer.speed = 1.0
                animationLayer.timeOffset = 0.0
                
                if let animationKey = animationKey {
                    startTime = animationLayer.convertTime(CACurrentMediaTime(), fromLayer: nil)
                    animationLayer.addAnimation(self, forKey: animationKey)
                }
        
            }
            
            if let subAnimations = animations {
                for animation in subAnimations {
                    if let subAnimation = animation as? FABasicAnimation,
                        let toValue = subAnimation.toValue {
                        
                        //TODO: Figure out why the opacity is not reflected on the UIView
                        //All properties work correctly, but to ensure that the opacity is reflected
                        //I am setting the alpha on the UIView itsel ?? WTF
                        if subAnimation.keyPath! == "opacity" {
                            animationLayer.owningView()!.setValue(toValue, forKeyPath: "alpha")
                        } else {
                            animationLayer.setValue(toValue, forKeyPath: subAnimation.keyPath!)
                        }
                    }
                }
            }
        }
    }
    
    
    /**
     Not Ready for Prime Time, being declared as private
     
     Adjusts animation based on the progress form 0 - 1
     
     - parameter progress: scrub "to progress" value
     */
    private func scrubToProgress(progress : CGFloat) {
        weakLayer?.speed = 0.0
        weakLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
    }
}


//MARK: - FASynchronizedGroup

public class FASynchronizedGroup : CAAnimationGroup {
    
    public var animationKey : String?
    internal var _timingPriority : FAPrimaryTimingPriority = .MaxTime
    
    internal var _autoreverse : Bool = false
    internal var _autoreverseCount: Int = 1
    internal var _autoreverseActiveCount: Int = 1
    internal var _autoreverseDelay: NSTimeInterval = 1.0
    internal var _autoreverseConfigured: Bool = false
    internal var _reverseEasingCurve: Bool = false
    
    public weak var weakLayer : CALayer? {
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
        let animationGroup = super.copyWithZone(zone) as! FASynchronizedGroup
        animationGroup.weakLayer                = weakLayer
        animationGroup.startTime                = startTime
        animationGroup.animationKey             = animationKey
        animationGroup.primaryAnimation         = primaryAnimation
        animationGroup._timingPriority          = _timingPriority
        animationGroup._autoreverse             = _autoreverse
        animationGroup._autoreverseCount        = _autoreverseCount
        animationGroup._autoreverseActiveCount  = _autoreverseActiveCount
        animationGroup._autoreverseConfigured   = _autoreverseConfigured
        animationGroup._autoreverseDelay        = _autoreverseDelay
        animationGroup._reverseEasingCurve      = _reverseEasingCurve
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
                    _autoreverseActiveCount = oldAnimation._autoreverseActiveCount
                    synchronizeAnimations(oldAnimation)
                }
            }
        } else {
            synchronizeAnimations(nil)
        }
    }
}

//MARK: - Auto Reverse Logic

internal extension FASynchronizedGroup {
 
    func configureAutoreverseIfNeeded() {
        
        if _autoreverse {
            
            if _autoreverseConfigured == false {
                configuredAutoreverseGroup()
            }
            
            if _autoreverseCount == 0 {
                return
            }
            
            if _autoreverseActiveCount >= (_autoreverseCount * 2) {
                clearAutoreverseGroup()
                return
            }
            
            _autoreverseActiveCount = _autoreverseActiveCount + 1
        }
    }
    
    func configuredAutoreverseGroup() {

        let animationGroup = FAAnimationGroup()
        
        animationGroup.animationKey             = animationKey! + "REVERSE"
        animationGroup.weakLayer                = weakLayer
        animationGroup.animations               = reverseAnimationArray()
        animationGroup.duration                 = duration
        animationGroup._timingPriority          = _timingPriority
        animationGroup._autoreverse             = _autoreverse
        animationGroup._autoreverseCount        = _autoreverseCount
        animationGroup._autoreverseActiveCount  = _autoreverseActiveCount
        animationGroup._reverseEasingCurve      = _reverseEasingCurve
   /*
        if let view =  weakLayer?.owningView() {
            let progressDelay = max(0.0 , _autoreverseDelay/duration)
            //configureAnimationTrigger(animationGroup, onView: view, atTimeProgress : 1.0 + CGFloat(progressDelay))
        }
    */
        removedOnCompletion = false
    }
    
    func clearAutoreverseGroup() {
        //_segmentArray = [FAAnimationTrigger]()
        // removedOnCompletion = true
        //stopTriggerTimer()
    }
    
    func reverseAnimationArray() ->[FABasicAnimation] {
        
        var reverseAnimationArray = [FABasicAnimation]()
        
        if let animations = animations {
            for animation in animations {
                if let customAnimation = animation as? FABasicAnimation {
                    
                    let newAnimation = FABasicAnimation(keyPath: customAnimation.keyPath)
                    newAnimation.easingFunction = _reverseEasingCurve ? customAnimation.easingFunction.reverseEasingCurve() : customAnimation.easingFunction
                    
                    newAnimation.isPrimary = customAnimation.isPrimary
                    newAnimation.values = customAnimation.values!.reverse()
                    newAnimation.toValue = customAnimation.fromValue
                    newAnimation.fromValue = customAnimation.toValue
                    
                    reverseAnimationArray.append(newAnimation)
                }
            }
        }
        
        return reverseAnimationArray
    }
}


//MARK: - Synchronization Logic

internal extension FASynchronizedGroup {
    
    /**
     Synchronizes the calling animation group with the passed animation group
     
     - parameter oldAnimationGroup: old animation in flight
     */
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
        
        configureAutoreverseIfNeeded()
    }
    
    /**
     Updates and syncronizes animations based on timing priority 
     if the primary animations
     
     - parameter durationArray: durations considered based on primary state of the animations
     */
    func updateGroupDurationBasedOnTimePriority(durationArray: Array<CFTimeInterval>) {
        
        switch _timingPriority {
        case .MaxTime:
            duration = durationArray.maxElement()!
        case .MinTime:
            duration = durationArray.minElement()!
        case .Median:
            duration = durationArray.sort(<)[durationArray.count / 2]
        case .Average:
            duration = durationArray.reduce(0, combine: +) / Double(durationArray.count)
        }
        
        let filteredAnimation = animations!.filter({ $0.duration == duration || _timingPriority == .Average || _timingPriority == .Median })
        
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


//MARK: - Animation Progress Values

internal extension FAAnimationGroup {
    
    func valueProgress() -> CGFloat {
    
        if let animation = weakLayer?.animationForKey(animationKey!) as? FAAnimationGroup{
            return animation.primaryAnimation!.valueProgress()
        }
        
        guard let primaryAnimation = primaryAnimation else {
            print("Primary Animation Nil")
            return 0.0
        }
        
        return primaryAnimation.valueProgress()
    }
    
    func timeProgress() -> CGFloat {
        
        
        if let animation = weakLayer?.animationForKey(animationKey!) as? FAAnimationGroup{
            return animation.primaryAnimation!.timeProgress()
        }
        
        guard let primaryAnimation = primaryAnimation else {
            print("Primary Animation Nil")
            return 0.0
        }
        
        return primaryAnimation.timeProgress()
    }
}
