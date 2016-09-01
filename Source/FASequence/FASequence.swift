//
//  FASequenceAnimator.swift
//  
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit

extension UIView {
    
    func cache(animation : Any, forKey key: String) {
        
        var cacheableSequence : FASequence?
        
        if let animation = animation as? FABasicAnimation {
           
            let group = animation.groupRepresentation()
            group.animationKey = key

            let sequence = FASequence()
            
            let startingTrigger = FASequenceTrigger(triggerAnimation: group, onView: self)
            
            sequence._sequenceTriggers[key] = startingTrigger
            cacheableSequence = sequence
  
        } else if let group = animation as? FAAnimationGroup {
        
            
            let sequence = FASequence()
            
            let startingTrigger = FASequenceTrigger(triggerAnimation: group, onView: self)
            
            sequence._sequenceTriggers[key] = startingTrigger
            
            cacheableSequence = sequence
            
        } else if let sequence = animation as? FASequence {
            
            cacheableSequence = sequence
        }
        
        if cachedSequences == nil {
            cachedSequences = [NSString : FASequence]()
        }
        
        cachedSequences![key] = cacheableSequence
    }
    
    func applyCachedAnimation(forKey key: String) {
        
        guard let cachedSequences = cachedSequences else {
            return
        }
        
        if let sequence = cachedSequences[key]  {
            sequence.startSequence()
        }
    }
}

public class FASequence {

   // internal var animationKey : String

    internal var displayLink : CADisplayLink?
    internal var sequenceKey : String?
    
    var sequenceTriggers = [String : FASequenceTrigger]()
    var _sequenceTriggers = [String : FASequenceTrigger]()
    
    func appendTrigger(trigger : FASequenceTrigger) {
         trigger.triggeredAnimation.animationKey = trigger.triggeredAnimation.animationKey ?? String(NSUUID().UUIDString)
        _sequenceTriggers[trigger.triggeredAnimation.animationKey!] = trigger
    }
}

extension FASequence {
    /*
    func trigger(animation: Any,
                 onView view : UIView,
                 onStartOfAnimation parent : FAAnimationGroup) {
     
        appendTrigger(parentAnimation : parent,
                      shouldTriggerAnimation  : animation,
                      onView : view)
    }
    
    func trigger(animation: Any,
                 onView view : UIView,
                 onCompletionOfAnimation parent : FAAnimationGroup) {
        
        appendTrigger(parentAnimation : parent,
                      shouldTriggerAnimation  : animation,
                      onView : view,
                      atProgress  : 1.0)
    }
    
    func trigger(animation: Any,
                 onView view : UIView,
                 atTimeProgress progress : CGFloat,
                 ofAnimation parent : Any) {
        
        appendTrigger(parentAnimation : parent,
                      shouldTriggerAnimation  : animation,
                      onView : view,
                      atProgress  : progress)
    }
    
    func trigger(animation: Any,
                 onView view : UIView,
                 atValueProgress progress : CGFloat,
                 ofAnimation parent : Any) {
        
        appendTrigger(parentAnimation : parent,
                      shouldTriggerAnimation  : animation,
                      onView : view ,
                      relativeToValue : true,
                      atProgress  : progress)
    }
 */
}

extension FASequence {
    
    func startSequence() {
        
        guard displayLink == nil else {
            return
        }
        
        sequenceTriggers = _sequenceTriggers
        displayLink = CADisplayLink(target: self, selector: #selector(FASequence.sequenceCurrentFrame))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        applyActiveSequenceTriggers()
    }
    
    func stopSequence() {
        
        sequenceTriggers = [String : FASequenceTrigger]()
        
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc internal func sequenceCurrentFrame() {
        applyActiveSequenceTriggers()
    }
    
    internal func applyActiveSequenceTriggers(forceFlush : Bool = false) {
        
        for (key, trigger) in sequenceTriggers {
            if trigger.triggerIfActive(forceFlush) {
                sequenceTriggers[key] = nil
            }
        }
        
        if sequenceTriggers.keys.count == 0 {
            stopSequence()
        }
    }
}

internal extension FASequence {
    
    func configfureInitialAnimation(animation : FAAnimationGroup, key: String?, view : UIView) {
        let startTrigger = FASequenceTrigger(triggerAnimation: animation, onView: view)
        
        if startTrigger.triggeredAnimation.animationKey == nil {
            startTrigger.triggeredAnimation.animationKey = key ?? String(NSUUID().UUIDString)
        }
        
        if startTrigger.triggeredAnimation.weakLayer == nil {
            startTrigger.triggeredAnimation.weakLayer = view.layer
        }
        
        _sequenceTriggers[startTrigger.triggeredAnimation.animationKey!] = startTrigger
    }
    /*
    func appendTrigger(parentAnimation parent : Any,
                       shouldTriggerAnimation child : Any,
                       onView view: UIView,
                       relativeToValue valueRelative: Bool = false,
                       atProgress progress : CGFloat = 0.0,
                       triggerOnRemoval : Bool = false) {
        
        
        var parentGroup : FAAnimationGroup?
        var childGroup : FAAnimationGroup?
        
        if let animation = parent as? FABasicAnimation {
            parentGroup = animation.groupRepresentation()
        } else if let group = parent as? FAAnimationGroup {
            parentGroup = group
        }
        
        if let animation = child as? FABasicAnimation {
            childGroup = animation.groupRepresentation()
        } else if let group = child as? FAAnimationGroup {
            childGroup = group
        }
        
        
        guard let triggerGroup = childGroup else {
            return
        }
        
        let trigger = FASequenceTrigger(triggerAnimation : triggerGroup, onView: view)
        
        trigger.animatingView = view
        trigger.parentAnimation = parentGroup
        trigger.isTimeRelative = !valueRelative
        trigger.triggerOnRemoval = triggerOnRemoval
        
        if trigger.triggeredAnimation.animationKey == nil {
            trigger.triggeredAnimation.animationKey = String(NSUUID().UUIDString)
        }
        
        if trigger.triggeredAnimation.weakLayer == nil {
            trigger.triggeredAnimation.weakLayer = view.layer
        }
        
        _sequenceTriggers[trigger.triggeredAnimation.animationKey!] = trigger
    }
 
 */
}