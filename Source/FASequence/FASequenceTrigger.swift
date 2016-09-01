//
//  FASequenceTrigger.swift
//
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit

public class FASequenceTrigger {
    
    internal weak var animatingView : UIView?
    
    internal var parentAnimation : FAAnimationGroup?
    internal var triggeredAnimation : FAAnimationGroup
    internal var isTimeRelative = true
    internal var progessValue : CGFloat = 0.0
    internal var triggerOnRemoval : Bool = false
    
    internal init(triggerAnimation animation : FAAnimationGroup, onView view: UIView) {
        animatingView = view
        triggeredAnimation = animation
        triggeredAnimation.animationKey = String(NSUUID().UUIDString)
        triggeredAnimation.weakLayer = view.layer
    }
    
    public func newSequenceTrigger(withAnimation animation : FAAnimationGroup,
                                   onView view: UIView,
                                   relativeToTime timeRelative: Bool = true,
                                   atProgress progress : CGFloat = 0.0,
                                   triggerOnRemoval : Bool = false) -> FASequenceTrigger {
        
        let chilAnimation = animation
        chilAnimation.weakLayer = view.layer
     
        let trigger = FASequenceTrigger(triggerAnimation : animation, onView: view)
        trigger.progessValue = progress
        trigger.triggeredAnimation = chilAnimation
        trigger.parentAnimation = triggeredAnimation
        trigger.isTimeRelative = timeRelative
        trigger.triggerOnRemoval = triggerOnRemoval
        trigger.animatingView = view
        
        return trigger
    }
    
    func triggerIfActive(forceAnimation : Bool = false) -> Bool {
        
        if shouldFireSegment() || (forceAnimation && triggerOnRemoval) {
            triggeredAnimation.applyFinalState(true, onView : animatingView)
            return true
        } else if forceAnimation {
            return true
        }
        
        return false
    }
    
    internal func shouldFireSegment() -> Bool {
        
        print ("Spin")
        
        if parentAnimation == nil { return true }
        
        print ("Parent AnimationKey :",  parentAnimation?.animationKey,  "   Progress :", parentAnimation?.timeProgress(),  "  ProgessValue :", progessValue)
        print(parentAnimation!.weakLayer!.animationForKey((parentAnimation?.animationKey)!))
        if let animKey = parentAnimation?.animationKey,
           let progressGroup = parentAnimation?.weakLayer?.animationForKey(animKey) as? FAAnimationGroup {
            
            print ("ProgressGroup AnimationKey :", animKey,  "   Progress :", progressGroup.timeProgress(),  "  ProgessValue :", progessValue)
            
            let fireTimeTrigger  = isTimeRelative && progressGroup.timeProgress() >= progessValue
            let fireValueTrigger = isTimeRelative == false && progressGroup.valueProgress() >= progessValue
            
            if fireTimeTrigger || fireValueTrigger  {
                return true
            }
        }
        /*
        let progressGroup = self.parentAnimation?.weakLayer?.animationForKey()
        
        
        let fireTimeTrigger  = isTimeRelative && parentAnimation?.timeProgress() >= progessValue
        let fireValueTrigger = isTimeRelative == false && parentAnimation?.valueProgress() >= progessValue
        let fireNoParentAnimation = parentAnimation == nil ? true : false
        
        if fireTimeTrigger || fireValueTrigger  || fireNoParentAnimation {
            return true
        }
        */
        return false
    }
}