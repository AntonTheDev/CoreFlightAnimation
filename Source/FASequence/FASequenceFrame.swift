//
//  FASequenceTrigger.swift
//
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit

public class FASequenceFrame {
    
    internal weak var animatingView : UIView?
    internal weak var delegate : FASequence?

    internal var parentAnimation : FAAnimationGroup?
    internal var triggeredAnimation : FAAnimationGroup!
    internal var isTimeRelative = true
    internal var progessValue : CGFloat = 0.0
    internal var triggerOnRemoval : Bool = false
    
    internal init(triggerAnimation animation : Any, onView view: UIView) {
        animatingView = view
    
        if let animation = animation as? FABasicAnimation {
            triggeredAnimation = animation.groupRepresentation()
            triggeredAnimation.animationKey = triggeredAnimation.animationKey ?? String(NSUUID().UUIDString)
            triggeredAnimation.weakLayer = view.layer
        } else if let group = animation as? FAAnimationGroup {
            triggeredAnimation = group
            triggeredAnimation.animationKey = triggeredAnimation.animationKey ?? String(NSUUID().UUIDString)
            triggeredAnimation.weakLayer = view.layer
        }
    }
    
    public func addSequenceFrame(withAnimation animation : Any,
                                 onView view: UIView,
                                 relativeToTime timeRelative: Bool = true,
                                atProgress progress : CGFloat = 0.0,
                                 triggerOnRemoval : Bool = false) -> FASequenceFrame {
  
        let trigger = FASequenceFrame(triggerAnimation : animation, onView: view)
        trigger.delegate = delegate
        
        if let animation = animation as? FABasicAnimation {
            trigger.triggeredAnimation = animation.groupRepresentation()
            trigger.triggeredAnimation.weakLayer = view.layer
        } else if let group = animation as? FAAnimationGroup {
            trigger.triggeredAnimation = group
            trigger.triggeredAnimation.weakLayer = view.layer
        }
        
        trigger.delegate = delegate
        trigger.animatingView = view
        trigger.progessValue = progress
        trigger.parentAnimation = triggeredAnimation
        trigger.isTimeRelative = timeRelative
        trigger.triggerOnRemoval = triggerOnRemoval

        trigger.triggeredAnimation.animationKey = String(NSUUID().UUIDString)
        delegate?._sequenceTriggers[trigger.triggeredAnimation.animationKey!] = trigger
        
        return trigger
    }
    
    func triggerIfActive(forceAnimation : Bool = false) -> Bool {
        
        if shouldFireSegment() || (forceAnimation && triggerOnRemoval) || forceAnimation {
            triggeredAnimation.applyFinalState(true)
            return true
        }
        
        return false
    }
    
    internal func shouldFireSegment() -> Bool {

        if parentAnimation == nil { return true }

        if let animKey = parentAnimation?.animationKey,
           let progressGroup = parentAnimation?.weakLayer?.animationForKey(animKey) as? FAAnimationGroup {

            let fireTimeTrigger  = isTimeRelative && progressGroup.timeProgress() >= progessValue
            let fireValueTrigger = isTimeRelative == false && progressGroup.valueProgress() >= progessValue
            
            if fireTimeTrigger || fireValueTrigger  {
                return true
            }
        }
        
        return false
    }
}