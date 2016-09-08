//
//  FASequence.swift
//  
//
//  Created by Anton on 9/3/16.
//
//

import Foundation
import UIKit

public protocol FAAnimatable  {
    
    var animationKey        : String?   { get set }
    var animatingLayer      : CALayer?  { get set }
    
    var isTimeRelative      : Bool      { get set }
    var progessValue        : CGFloat   { get set }
    var triggerOnRemoval    : Bool      { get set }
    
    func applyFinalState(animated : Bool)
}

public protocol FASequenceAnimatable {
    var animation : FAAnimatable? { get set }
}

public class FASequence : FASequenceAnimatable {
    
    public var animation : FAAnimatable?

    internal var queuedTriggers = [(parent : FASequenceAnimation , child : FASequenceAnimation)]()
    internal var displayLink : CADisplayLink?
  
    internal var isAnimating : Bool {
        get { return displayLink != nil }
    }
    
    public init() { }

    public func startSequence() {

        guard isAnimating == false else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(FASequenceAnimation.sequenceCurrentFrame))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        animation?.applyFinalState(true)
    }
    
    public func stopSequence() {
       
        displayLink?.invalidate()
        displayLink = nil
        
        queuedTriggers = [(parent : FASequenceAnimation , child : FASequenceAnimation)]()
    }
    
    @objc internal func sequenceCurrentFrame() {
        applyActiveSequenceTriggers()
    }
    
    public func applyActiveSequenceTriggers(forceAnimation : Bool = false) {
        
        for trigger in queuedTriggers {
            if trigger.child.shouldTriggerRelativeTo(trigger.parent, forceAnimation:forceAnimation) {

                queuedTriggers = queuedTriggers.filter { !($0.child == trigger.child && $0.parent == trigger.parent) }
            }
        }

        if queuedTriggers.count == 0 { stopSequence() }
    }
    
    public func applyFinalState(animated : Bool) {
        startSequence()
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
                        
                        if subAnimation.duration <= 0 {
                            return
                        }
                        
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