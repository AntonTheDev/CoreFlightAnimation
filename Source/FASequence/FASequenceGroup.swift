//
//  FASequenceAnimator.swift
//  
//
//  Created by Anton on 8/26/16.
//
//

import Foundation

public class FASequenceGroup : FASequence {
    
    // [ Parent : Child ]
    public var sequenceAnimations = [FASequenceAnimation : FASequenceAnimation]()
    
    override public func startSequence() {
        guard isAnimating == false else { return }
        queuedTriggers = sequenceAnimations
        super.startSequence()
    }
}