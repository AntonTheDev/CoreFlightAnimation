//
//  FAAnimation.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 9/1/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public protocol FASequenceAnimatable : class {
    
    var parentAnimatable : FASequenceAnimatable? { get set }
    
    var animationKey : String? { get set }
    weak var animatingLayer : CALayer? { get set }
    
    var startTime : CFTimeInterval? { get set }

    func sequenceRepresentation() -> FASequence?
    func groupRepresentation() -> FAAnimationGroup?
}

extension FAAnimationGroup : FASequenceAnimatable {
    
    public func sequenceRepresentation() -> FASequence? {
        if let view = animatingLayer?.owningView() {
            return FASequence(onView: view, withAnimation: self, forKey: animationKey)
        }
        return nil
    }
    
    public func groupRepresentation() -> FAAnimationGroup? {
        return self
    }
}

extension FABasicAnimation : FASequenceAnimatable {
    
    public func sequenceRepresentation() -> FASequence? {
        if let view = self.animatingLayer?.owningView(), group = groupRepresentation() {
            return FASequence(onView: view, withAnimation: group, forKey: animationKey)
        }
        
        return nil
    }
    
    public func groupRepresentation() -> FAAnimationGroup? {
        
        let newAnimationGroup = FAAnimationGroup()
        
        newAnimationGroup.animationKey             = animationKey ?? String(NSUUID().UUIDString)
        newAnimationGroup.animatingLayer           = animatingLayer
        newAnimationGroup.startTime                = startTime
        
        newAnimationGroup.autoreverse              = autoreverse
        newAnimationGroup.autoreverseCount         = autoreverseCount
        newAnimationGroup._autoreverseActiveCount  = _autoreverseActiveCount
        newAnimationGroup._autoreverseConfigured   = _autoreverseConfigured
        newAnimationGroup.autoreverseDelay         = autoreverseDelay
        newAnimationGroup.autoreverseEasing       = autoreverseEasing
        
        newAnimationGroup.animations = [self]
        
        return newAnimationGroup
    }
}