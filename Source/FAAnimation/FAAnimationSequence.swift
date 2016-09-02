//
//  FASequenceAnimator.swift
//  
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit

public extension UIView {
    public func cacheAnimation(animation : FAAnimationSequenceType, forKey key: String) {
        cachedSequences[key] = animation.sequenceRepresentation()
    }
}

public class FASequenceTrigger {
    
    internal weak var parentSequence : FAAnimationSequence?
    
    internal var parentAnimation : FAAnimationGroup?
    public var triggeredAnimation : FAAnimationGroup!
    
    internal var isTimeRelative = true
    internal var progessValue : CGFloat = 0.0
    internal var triggerOnRemoval : Bool = false
    
    public func addSequenceFrame(withAnimation animation : FAAnimationSequenceType,
                                               onView view: UIView,
                                                      relativeToTime timeRelative: Bool = true,
                                                                     atProgress progress : CGFloat = 0.0,
                                                                                triggerOnRemoval : Bool = false) -> FASequenceTrigger {
        
        return parentSequence!.addSequenceFrame(withAnimation : animation,
                                                onView : view,
                                                relativeToTime : timeRelative,
                                                atProgress  : progress,
                                                triggerOnRemoval : triggerOnRemoval,
                                                relativeAnimation : triggeredAnimation)
    }
}

public class FAAnimationSequence  {

    public weak var weakLayer : CALayer?
    public var animationKey : String?

    internal var initialTriggerKey : String!
    
    internal var displayLink : CADisplayLink?

    internal var sequenceTriggers = [String : FASequenceTrigger]()
    internal var _sequenceTriggers = [String : FASequenceTrigger]()
    
    internal var _autoreverse : Bool = false
    internal var _autoreverseCount: Int = 1
    internal var _autoreverseDelay: NSTimeInterval = 1.0
    internal var _reverseEasingCurve: Bool = false
    
    required public init(onView view: UIView, withAnimation animation : FAAnimationSequenceType?, forKey key: String? = nil) {
    
        weakLayer = view.layer
        animationKey = key ?? String(NSUUID().UUIDString)
        initialTriggerKey = animationKey
        
        let triggerAnimation = animation?.groupRepresentation() ?? FAAnimationGroup()
        triggerAnimation.weakLayer = weakLayer
        triggerAnimation.animationKey = animationKey
        
        initialTriggerKey = triggerAnimation.animationKey
        initialTriggerKey = animationKey

        let initialTrigger = FASequenceTrigger()
        initialTrigger.parentSequence = self
        initialTrigger.triggeredAnimation = triggerAnimation
        
        _sequenceTriggers[initialTriggerKey] = initialTrigger
    }
}

extension FAAnimationSequence {
    
    final public func addSequenceFrame(withAnimation animation : FAAnimationSequenceType,
                                       onView view: UIView,
                                       relativeToTime timeRelative: Bool = true,
                                       atProgress progress : CGFloat = 0.0,
                                       triggerOnRemoval : Bool = false,
                                       relativeAnimation : FAAnimationSequenceType? = nil ) -> FASequenceTrigger {
        
        let triggerKey = animation.animationKey ?? String(NSUUID().UUIDString)
        let triggerParentAnimation = relativeAnimation ?? _sequenceTriggers[initialTriggerKey]?.triggeredAnimation
        
        let triggerAnimation = animation.groupRepresentation() ?? FAAnimationGroup()
        triggerAnimation.weakLayer = view.layer
        triggerAnimation.animationKey = triggerKey
    
        let trigger = FASequenceTrigger()
        trigger.parentSequence = self
        trigger.parentAnimation = triggerParentAnimation?.groupRepresentation()
        trigger.triggeredAnimation = triggerAnimation
        trigger.isTimeRelative = timeRelative
        trigger.progessValue = progress
        trigger.triggerOnRemoval = triggerOnRemoval
        
        _sequenceTriggers[triggerKey] = trigger
        
        return trigger
    }
}

extension FAAnimationSequence {
    
    func startSequence() {
        
        guard displayLink == nil else {
            return
        }
       
        displayLink = CADisplayLink(target: self, selector: #selector(FAAnimationSequence.sequenceCurrentFrame))
        
        sequenceTriggers = _sequenceTriggers
        
        sequenceTriggers[initialTriggerKey]?.triggeredAnimation?.applyFinalState(true)
        sequenceTriggers[initialTriggerKey] = nil
        
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func stopSequence() {
        sequenceTriggers = [String : FASequenceTrigger]()
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc internal func sequenceCurrentFrame() {
        applyActiveSequenceTriggers()
    }
    
    internal func applyActiveSequenceTriggers(forceAnimation : Bool = false) {
        
        for (key, trigger) in sequenceTriggers {
            if triggerSegmentIfActive(trigger, forceAnimation : forceAnimation) {
                sequenceTriggers[key] = nil
            }
        }
        
        if sequenceTriggers.keys.count == 0 {
            stopSequence()
        }
    }
    
    internal func triggerSegmentIfActive(segment: FASequenceTrigger, forceAnimation : Bool = false) -> Bool {
        
        if segment.parentAnimation == nil {
            segment.triggeredAnimation.applyFinalState(true)
            return true
        }
        
        if let animKey = segment.parentAnimation?.animationKey,
           let animationgLayer = segment.parentAnimation?.weakLayer,
           let runningAnimationGroup = animationgLayer.animationForKey(animKey) as? FAAnimationGroup {
            
            let fireTimeTrigger  = segment.isTimeRelative && runningAnimationGroup.timeProgress() >= segment.progessValue
            let fireValueTrigger = segment.isTimeRelative == false && runningAnimationGroup.valueProgress() >= segment.progessValue
      
            if fireTimeTrigger || fireValueTrigger || forceAnimation  {
                segment.triggeredAnimation.applyFinalState(true)
                return true
            }
        }
        
        return false
    }
    
}