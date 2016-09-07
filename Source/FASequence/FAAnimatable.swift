//
//  FAAnimatable.swift
//  CoreFlightAnimation
//
//  Created by Anton on 9/7/16.
//
//

import Foundation

public protocol FAAnimatable : class {
    
    var animationKey        : String?   { get set }
    var animatingLayer      : CALayer?  { get set }
    
    var isTimeRelative      : Bool      { get set }
    var progessValue        : CGFloat   { get set }
    var triggerOnRemoval    : Bool      { get set }
    
    func applyFinalState(animated : Bool)
}

public protocol FASequenceAnimatable : FAAnimatable {
    var initialTrigger : FASequenceAnimatable? { get set }
}

public func ==(lhs:FASequence, rhs:FASequence) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension FASequence : Hashable {
    public var hashValue: Int {
        return animationKey?.hashValue ?? 0
    }
}

extension FAAnimationGroup : FAAnimatable {
    
    public func applyFinalState(animated : Bool = false) {
        
        if let animatingLayer = animatingLayer {
            if animated {
                animatingLayer.speed = 1.0
                animatingLayer.timeOffset = 0.0
                
                if let animationKey = animationKey {
                    startTime = animatingLayer.convertTime(CACurrentMediaTime(), fromLayer: nil)
                    animatingLayer.addAnimation(self, forKey: animationKey)
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
                            animatingLayer.owningView()!.setValue(toValue, forKeyPath: "alpha")
                        } else {
                            animatingLayer.setValue(toValue, forKeyPath: subAnimation.keyPath!)
                        }
                    }
                }
            }
        }
    }
}


extension FABasicAnimation : FAAnimatable {
    
    public func applyFinalState(animated : Bool = false) {
        
        let newAnimationGroup = FAAnimationGroup()
        
        newAnimationGroup.animationKey             = animationKey ?? String(NSUUID().UUIDString)
        newAnimationGroup.animatingLayer           = animatingLayer
        newAnimationGroup.startTime                = startTime
        
        newAnimationGroup.autoreverse              = autoreverse
        newAnimationGroup.autoreverseCount         = autoreverseCount
        newAnimationGroup._autoreverseActiveCount  = _autoreverseActiveCount
        newAnimationGroup._autoreverseConfigured   = _autoreverseConfigured
        newAnimationGroup.autoreverseDelay         = autoreverseDelay
        newAnimationGroup.autoreverseEasing        = autoreverseEasing
        
        newAnimationGroup.animations = [self]
        
        newAnimationGroup.applyFinalState(animated)
    }
}