//
//  FASequenceAnimator.swift
//  
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit


public func ==(lhs:FASequenceAnimationGroup, rhs:FASequenceAnimationGroup) -> Bool {
    return lhs.animationKey == rhs.animationKey
}

extension FASequenceAnimationGroup : FASequenceAnimatable {

    public func applyFinalState(animated : Bool) {
        guard isAnimating == false else { return }
        queuedTriggers = sequenceAnimations
        super.startSequence()
    }
}

public class FASequenceAnimationGroup : FASequence {
    
    public var animation : FASequenceAnimatable? {
        get {
            return rootSequenceAnimation
        } set {
            rootSequenceAnimation = newValue
        }
    }

    public var animationKey  : String?
    public var animatingLayer : CALayer?
    
    public var isTimeRelative = true
    public var progessValue : CGFloat = 0.0
    public var triggerOnRemoval : Bool = false
}