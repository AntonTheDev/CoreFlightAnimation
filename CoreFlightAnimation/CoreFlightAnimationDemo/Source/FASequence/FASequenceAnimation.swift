//
//  FASequenceTrigger.swift
//  CoreFlightAnimation
//
//  Created by Anton on 9/3/16.
//
//

import Foundation
import UIKit

public func ==(lhs:FASequenceAnimation, rhs:FASequenceAnimation) -> Bool {
    return lhs.animationKey == rhs.animationKey
}

public class FASequenceAnimation : FASequence, FAAnimatable {

    public var animationKey  : String?
    public var animatingLayer : CALayer?
    
    public var isTimeRelative = true
    public var progessValue : CGFloat = 0.0
    public var triggerOnRemoval : Bool = false

    required public init(onView view : UIView) {
        super.init()
        animatingLayer = view.layer
        animationKey = String(NSUUID().UUIDString)
    }
    
    convenience required public init(onView view : UIView,
                                            withAnimation anim: FAAnimatable,
                                            forKey key : String? = nil) {
        self.init(onView: view)
        
        animation = anim
        animatingLayer = view.layer
        animationKey = key ??  String(NSUUID().UUIDString)
    }
    
    internal func shouldTriggerRelativeTo(parent : FASequenceAnimation?, forceAnimation : Bool = false) -> Bool {
        
        if parent == nil {
            animation?.animatingLayer = animatingLayer
            animation?.animationKey = animationKey
            animation?.applyFinalState(true)
            return true
        }
        
        if let animKey = parent?.animation?.animationKey,
            let animationgLayer = parent?.animation?.animatingLayer,
            let runningAnimationGroup = animationgLayer.animationForKey(animKey) as? FAAnimationGroup {
            
            let fireTimeTrigger  = isTimeRelative && runningAnimationGroup.timeProgress() >= progessValue
            let fireValueTrigger = isTimeRelative == false && runningAnimationGroup.valueProgress() >= progessValue
            
            if fireTimeTrigger || fireValueTrigger || forceAnimation  {
                animation?.animationKey = animationKey
                animation?.animatingLayer = animatingLayer
                animation?.applyFinalState(true)
                return true
            }
        }
        
        return false
    }
    
    override public func startSequence() {
        guard isAnimating == false else { return }
        animation?.animatingLayer = animatingLayer
        animation?.animationKey = animationKey
        super.startSequence()
    }
    
    override public func applyFinalState(animated : Bool) {
        animation?.animatingLayer = animatingLayer
        animation?.animationKey = animationKey
        animation?.applyFinalState(animated)
    }
}
