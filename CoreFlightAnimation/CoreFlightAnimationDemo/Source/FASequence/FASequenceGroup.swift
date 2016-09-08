//
//  FASequenceAnimator.swift
//  
//
//  Created by Anton on 8/26/16.
//
//

import Foundation
import UIKit

public func ==(lhs:FASequenceGroup, rhs:FASequenceGroup) -> Bool {
    return lhs.animationKey == rhs.animationKey
}

public class FASequenceGroup : FASequence {
    
    public var animationKey  : String?
    public var animatingLayer : CALayer?
    
    public var isTimeRelative = true
    public var progessValue : CGFloat = 0.0
    public var triggerOnRemoval : Bool = false

    
    // [ Parent : Child ]
    public var sequenceAnimations = [(parent : FASequenceAnimation , child : FASequenceAnimation)]()
    
    override public func startSequence() {
        guard isAnimating == false else { return }
        queuedTriggers = sequenceAnimations
        super.startSequence()
    }
    
    public func appendSequenceAnimation(child : FASequenceAnimation, relativeTo parent : FASequenceAnimation) {
        self.sequenceAnimations.append((parent : parent , child : child))
    }
}