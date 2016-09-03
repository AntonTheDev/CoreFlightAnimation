//
//  FASequenceAnimator.swift
//  
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit


public class FASequence  {

    public weak var animatingLayer : CALayer?
    
    public var animationKey : String?
    public var startTime : CFTimeInterval?
    
    internal var initialTriggerKey : String!
    internal var displayLink : CADisplayLink?
    
    internal var sequenceTriggers = [String : FASequenceTrigger]()
    internal var _sequenceTriggers = [String : FASequenceTrigger]()
    
    public var autoreverse: Bool = false
    public var autoreverseCount: Int = 1
    public var autoreverseDelay: NSTimeInterval = 0.0
    public var autoreverseEasing: Bool = false
    
    required public init(onView view: UIView, withAnimation animation : FASequenceAnimatable?, forKey key: String? = nil) {
    
        animatingLayer = view.layer
        animationKey = key ?? String(NSUUID().UUIDString)
        initialTriggerKey = animationKey
        
        let triggerAnimation = animation?.groupRepresentation() ?? FAAnimationGroup()
        triggerAnimation.animatingLayer = animatingLayer
        triggerAnimation.animationKey = animationKey
        
        initialTriggerKey = triggerAnimation.animationKey
        initialTriggerKey = animationKey

        let initialTrigger = FASequenceTrigger()
        initialTrigger.parentSequence = self
        initialTrigger.triggeredAnimation = triggerAnimation
        
        _sequenceTriggers[initialTriggerKey] = initialTrigger
    }
}

extension FASequence {
    
    final public func addSequenceFrame(withAnimation animation : FASequenceAnimatable,
                                       onView view: UIView,
                                       relativeToTime timeRelative: Bool = true,
                                       atProgress progress : CGFloat = 0.0,
                                       triggerOnRemoval : Bool = false,
                                       relativeAnimation : FASequenceAnimatable? = nil ) -> FASequenceTrigger {
        
        let triggerKey = animation.animationKey ?? String(NSUUID().UUIDString)
        let triggerParentAnimation = relativeAnimation ?? _sequenceTriggers[initialTriggerKey]?.triggeredAnimation
        
        let triggerAnimation = animation.groupRepresentation() ?? FAAnimationGroup()
        triggerAnimation.animatingLayer = view.layer
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

public extension FASequence {
    
    public func startSequence() {
        
        guard displayLink == nil else {
            return
        }
       
        displayLink = CADisplayLink(target: self, selector: #selector(FASequence.sequenceCurrentFrame))
        
        sequenceTriggers = _sequenceTriggers
        
        sequenceTriggers[initialTriggerKey]?.triggeredAnimation?.applyFinalState(true)
        sequenceTriggers[initialTriggerKey] = nil
        
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    public func stopSequence() {
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
           let animationgLayer = segment.parentAnimation?.animatingLayer,
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