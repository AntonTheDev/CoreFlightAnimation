//
//  FASequenceAnimator.swift
//  
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit

public class FASequence {
    
    internal var startingTrigger : FASequenceFrame
    
    internal var displayLink : CADisplayLink?
    internal var sequenceKey : String?
    
    internal var sequenceTriggers = [String : FASequenceFrame]()
    internal var _sequenceTriggers = [String : FASequenceFrame]()
    
    required public init(onView view: UIView, withAnimation animation : Any) {
       startingTrigger = FASequenceFrame(triggerAnimation: animation, onView: view)
       startingTrigger.delegate = self
    }

    final public func addSequenceFrameFrame(withAnimation animation : Any,
                                            onView view: UIView,
                                            relativeToTime timeRelative: Bool = true,
                                            atProgress progress : CGFloat = 0.0,
                                            triggerOnRemoval : Bool = false) -> FASequenceFrame {
        
        let trigger = FASequenceFrame(triggerAnimation : animation, onView: view)
        trigger.delegate = self
        
        if let animation = animation as? FABasicAnimation {
            trigger.triggeredAnimation = animation.groupRepresentation()
            trigger.triggeredAnimation.weakLayer = view.layer
        } else if let group = animation as? FAAnimationGroup {
            trigger.triggeredAnimation = group
            trigger.triggeredAnimation.weakLayer = view.layer
        }
        
        trigger.delegate = self
        trigger.animatingView = view
        trigger.progessValue = progress
        trigger.parentAnimation = startingTrigger.triggeredAnimation
        trigger.isTimeRelative = timeRelative
        trigger.triggerOnRemoval = triggerOnRemoval
        
        trigger.triggeredAnimation.animationKey = trigger.triggeredAnimation.animationKey ?? String(NSUUID().UUIDString)
        _sequenceTriggers[trigger.triggeredAnimation.animationKey!] = trigger
        
        return trigger
    }
}

extension UIView {
    
    func cache(animation : Any, forKey key: String) {
        
        var cacheableSequence : FASequence?
        
        if let animation = animation as? FABasicAnimation {
            let group = animation.groupRepresentation()
            group.animationKey = key
            
            cacheableSequence = FASequence(onView: self, withAnimation: group)
        }
        else if let group = animation as? FAAnimationGroup {
            cacheableSequence =  FASequence(onView: self, withAnimation: group)
        }
        else if let sequence = animation as? FASequence {
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

extension FASequence {
    
    /*
    func trigger(animation: Any,
                 onView view : UIView,
                 onStartOfAnimation parent : FAAnimationGroup) -> FASequenceFrame {
     
        addSequenceFrameFrame(parentAnimation : parent,
                      shouldTriggerAnimation  : animation,
                      onView : view)
    }
    
    func trigger(animation: Any,
                 onView view : UIView,
                 onCompletionOfAnimation parent : FAAnimationGroup) -> FASequenceFrame {
        
        addSequenceFrameFrame(parentAnimation : parent,
                      shouldTriggerAnimation  : animation,
                      onView : view,
                      atProgress  : 1.0)
    }
    
    func trigger(animation: Any,
                 onView view : UIView,
                 atTimeProgress progress : CGFloat,
                 ofAnimation parent : Any) -> FASequenceFrame {
        
        addSequenceFrameFrame(parentAnimation : parent,
                      shouldTriggerAnimation  : animation,
                      onView : view,
                      atProgress  : progress)
    }
    
    func trigger(animation: Any,
                 onView view : UIView,
                 atValueProgress progress : CGFloat,
                 ofAnimation parent : Any)  -> FASequenceFrame {
        
        addSequenceFrameFrame(parentAnimation : parent,
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
       
        startingTrigger.triggeredAnimation.applyFinalState(true)
    }
    
    func stopSequence() {
        sequenceTriggers = [String : FASequenceFrame]()
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