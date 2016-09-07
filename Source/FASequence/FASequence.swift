//
//  FASequence.swift
//  
//
//  Created by Anton on 9/3/16.
//
//

import Foundation


public class FASequence : FASequenceAnimatable {
    
    public var initialTrigger : FASequenceAnimatable?
    
    public var animationKey  : String?
    public var animatingLayer : CALayer?
    
    public var isTimeRelative = true
    public var progessValue : CGFloat = 0.0
    public var triggerOnRemoval : Bool = false

    internal var queuedTriggers = [FASequenceAnimation : FASequenceAnimation]()
    internal var displayLink : CADisplayLink?
  
    internal var isAnimating : Bool {
        get { return displayLink != nil }
    }
    
    public init() { }

    public func startSequence() {

        guard isAnimating == false else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(FASequenceAnimation.sequenceCurrentFrame))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        initialTrigger?.applyFinalState(true)
    }
    
    public func stopSequence() {
       
        displayLink?.invalidate()
        displayLink = nil
        
        queuedTriggers = [FASequenceAnimation : FASequenceAnimation]()
    }
    
    @objc internal func sequenceCurrentFrame() {
        applyActiveSequenceTriggers()
    }
    
    public func applyActiveSequenceTriggers(forceAnimation : Bool = false) {
        
         for (parent, child) in queuedTriggers {
            if child.shouldTriggerRelativeTo(parent, forceAnimation : forceAnimation) {
                queuedTriggers[parent] = nil
            }
         }
         
         if queuedTriggers.keys.count == 0 { stopSequence() }
    }
    
    public func applyFinalState(animated : Bool) {
        startSequence()
    }
} 