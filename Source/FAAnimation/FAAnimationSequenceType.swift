//
//  FAAnimation.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 9/1/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public protocol FAAnimationSequenceType : class {
    
    var animationKey : String? { get set }
    
    weak var weakLayer : CALayer? { get set }
    
    /**
     Quick helper to transform an FAAnimationType into
     an FASequence
     
     - returns: FASequence representation of an animationType
     */
    func sequenceRepresentation() -> FAAnimationSequence?
    
    
    /**
     Quick helper to transform an FAAnimationType into
     an FAAnimationGroup
     
     - returns: FAAnimationGroup representation of an animationType
     */
    func groupRepresentation() -> FAAnimationGroup?
    
    
    /**
     Enable Autoreverse of the animation.
     
     By default it will only auto revese once.
     Adjust the autoreverseCount to change that
     
     */
    var autoreverse: Bool { get set }
    
    /**
     Count of times to repeat the reverse animation
     
     Default is 1, set to 0 repeats the animation
     indefinitely until is removed manually from the layer.
     */
    var autoreverseCount: Int { get set }
    
    
    /**
     Delay in seconds to perfrom reverse animation.
     
     Once the animation completes this delay adjusts the
     pause prior to triggering the reverse animation
     
     Default is 0.0
     */
    var autoreverseDelay: NSTimeInterval { get set }
    
    
    /**
     Delay in seconds to perfrom reverse animation.
     
     Once the animation completes this delay adjusts the
     pause prior to triggering the reverse animation
     
     Default is 0.0
     */
    var reverseEasingCurve: Bool { get set }
}


extension FAAnimationSequence : FAAnimationSequenceType {
    
    public var autoreverse: Bool {
        get { return _autoreverse }
        set { _autoreverse = newValue }
    }
    
    public var autoreverseCount: Int {
        get { return _autoreverseCount }
        set { _autoreverseCount = newValue }
    }
    
    public var autoreverseDelay: NSTimeInterval {
        get { return _autoreverseDelay }
        set { _autoreverseDelay = newValue }
    }
    
    public var reverseEasingCurve: Bool {
        get { return _reverseEasingCurve }
        set { _reverseEasingCurve = newValue }
    }
    
    public func sequenceRepresentation() -> FAAnimationSequence? {
        return self
    }
    
    public func groupRepresentation() -> FAAnimationGroup? {
        return nil
    }
}

extension FASynchronizedGroup : FAAnimationSequenceType {
    
    public var autoreverse: Bool {
        get { return _autoreverse }
        set { _autoreverse = newValue }
    }
    
    public var autoreverseCount: Int {
        get { return _autoreverseCount }
        set { _autoreverseCount = newValue }
    }
    
    public var autoreverseDelay: NSTimeInterval {
        get { return _autoreverseDelay }
        set { _autoreverseDelay = newValue }
    }
    
    public var reverseEasingCurve: Bool {
        get { return _reverseEasingCurve }
        set { _reverseEasingCurve = newValue }
    }
    
    public func sequenceRepresentation() -> FAAnimationSequence? {
        if let view = weakLayer?.owningView() {
            return FAAnimationSequence(onView: view, withAnimation: self, forKey: animationKey)
        }
        return nil
    }
    
    public func groupRepresentation() -> FAAnimationGroup? {
        return self as? FAAnimationGroup
    }
}

extension FABasicAnimation : FAAnimationSequenceType {
    
    public var autoreverse: Bool {
        get { return _autoreverse }
        set { _autoreverse = newValue }
    }
    
    public var autoreverseCount: Int {
        get { return _autoreverseCount }
        set { _autoreverseCount = newValue }
    }
    
    public var autoreverseDelay: NSTimeInterval {
        get { return _autoreverseDelay }
        set { _autoreverseDelay = newValue }
    }
    
    public var reverseEasingCurve: Bool {
        get { return _reverseEasingCurve }
        set { _reverseEasingCurve = newValue }
    }
    
    public func sequenceRepresentation() -> FAAnimationSequence? {
        if let view = self.weakLayer?.owningView(), group = groupRepresentation() {
            return FAAnimationSequence(onView: view, withAnimation: group, forKey: animationKey)
        }
        
        return nil
    }
    
    public func groupRepresentation() -> FAAnimationGroup? {
        
        let newAnimationGroup = FAAnimationGroup()
        newAnimationGroup.animationKey          = animationKey ?? String(NSUUID().UUIDString)
        newAnimationGroup.weakLayer             = weakLayer
        newAnimationGroup.startTime             = startTime
        
        newAnimationGroup._autoreverse             = _autoreverse
        newAnimationGroup._autoreverseCount        = _autoreverseCount
        newAnimationGroup._autoreverseActiveCount  = _autoreverseActiveCount
        newAnimationGroup._autoreverseConfigured   = _autoreverseConfigured
        newAnimationGroup._autoreverseDelay        = _autoreverseDelay
        newAnimationGroup._reverseEasingCurve      = _reverseEasingCurve
        
        newAnimationGroup.animations = [self]
        
        return newAnimationGroup
    }
}