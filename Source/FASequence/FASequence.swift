//
//  FASequence.swift
//
//
//  Created by Anton on 9/3/16.
//
//

import Foundation
import UIKit

public protocol FASequenceAnimatable : FASequenceTrigger  {
    
    weak var sequenceDelegate    : FASequenceDelegate? { get set }
    
    var animation           : FASequenceAnimatable? { get set }
    var reverseAnimation    : FASequenceAnimatable? { get set }
    
    var animationUUID       : String?   { get set }
    var animatingLayer      : CALayer?  { get set }
    
    var timeRelative        : Bool      { get set }
    var progessValue        : CGFloat   { get set }
    var triggerOnRemoval    : Bool      { get set }
    
    var duration            : NSTimeInterval    { get set }
    
    var autoreverse         : Bool              { get set }
    var autoreverseCount    : Int               { get set }
    var autoreverseDelay    : NSTimeInterval    { get set }
    var autoreverseEasing   : Bool              { get set }
    
    func applyFinalState(animated : Bool)
    
    func sequenceCopy() -> FASequenceAnimatable
}

public protocol FASequenceTrigger :  class {
    
    func appendSequenceAnimationOnStart(child : FASequenceAnimatable, onView view: UIView) -> FASequenceTrigger?
    
    func appendSequenceAnimation(child : FASequenceAnimatable, onView view: UIView) -> FASequenceTrigger?
    func appendSequenceAnimation(child : FASequenceAnimatable, onView view: UIView, atProgress progress : CGFloat) -> FASequenceTrigger?
    func appendSequenceAnimation(child : FASequenceAnimatable, onView view: UIView, atValueProgress progress : CGFloat) -> FASequenceTrigger?
}

public protocol FASequenceDelegate : FASequenceTrigger {
    func appendSequenceAnimation(child : FASequenceAnimatable, relativeTo parent : FASequenceAnimatable) -> FASequenceTrigger?
}

public class FASequence  {
    
    public var rootSequenceAnimation : FASequenceAnimatable? {
        didSet { rootSequenceAnimation?.sequenceDelegate = self }
    }
    
    // [ Parent : Child ]
    internal var sequenceAnimations = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
    internal var queuedTriggers = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
    
    internal var displayLink : CADisplayLink?
    
    public var autoreverse: Bool = false
    public var autoreverseCount: Int = 1
    public var autoreverseDelay: NSTimeInterval = 0.0
    public var autoreverseEasing: Bool = false
    
    internal var autoreverseActiveCount: Int = 1
    
    internal var isAnimating : Bool {
        get { return displayLink != nil }
    }
    
    public init() { }
}

// MARK: - FASequenceDelegate : FASequenceTrigger

extension FASequence : FASequenceDelegate {
    
    public func setRootSequenceAnimation(child : FASequenceAnimatable, onView view: UIView) {
        let childAnimatable = child.sequenceCopy()
        childAnimatable.animatingLayer = view.layer
        rootSequenceAnimation = childAnimatable
    }

    public func appendSequenceAnimationOnStart(child : FASequenceAnimatable,
                                               onView view: UIView) -> FASequenceTrigger? {
    
        return configuredSequenceCopy(child, onView: view, progress: 0.0, timeRelative: true)
    }

    public func appendSequenceAnimation(child : FASequenceAnimatable,
                                        onView view: UIView,
                                        atValueProgress progress : CGFloat) -> FASequenceTrigger? {
        return configuredSequenceCopy(child, onView: view, progress: progress, timeRelative: false)
    }
    
    public func appendSequenceAnimation(child : FASequenceAnimatable,
                                        onView view: UIView,
                                        atProgress progress : CGFloat) -> FASequenceTrigger? {
        
        return configuredSequenceCopy(child, onView: view, progress: progress)
    }

    public func appendSequenceAnimation(child : FASequenceAnimatable,
                                        onView view: UIView) -> FASequenceTrigger? {
        return configuredSequenceCopy(child, onView: view, progress: child.progessValue, timeRelative: child.timeRelative)
    }

    public func appendSequenceAnimation(child : FASequenceAnimatable, relativeTo parent : FASequenceAnimatable) -> FASequenceTrigger?  {
        sequenceAnimations.append((parent : parent , child : child))
        return child
    }

    private func configuredSequenceCopy(child : FASequenceAnimatable,
                                        onView view: UIView,
                                        progress : CGFloat = 0.0,
                                        timeRelative : Bool = true) -> FASequenceAnimatable {
        
        let sequence = child.sequenceCopy() 
        
        sequence.animatingLayer     = view.layer
        sequence.animationUUID      = String(NSUUID().UUIDString)
        sequence.progessValue       = progress
        sequence.timeRelative       = timeRelative
        sequence.sequenceDelegate   = self
        
        if let rootSequenceAnimation = rootSequenceAnimation {
            sequenceAnimations.append((parent : rootSequenceAnimation , child : sequence))
        }
        
        return sequence
    }
}

// MARK: - Trigger Logic

public extension FASequence {
    
    public func startSequence() {
        
        guard isAnimating == false else { return }
        
        synchronizeRootSequenceTriggers()
        
        displayLink = CADisplayLink(target: self, selector: #selector(FASequence.sequenceCurrentFrame))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        rootSequenceAnimation?.applyFinalState(true)
    }
    
    public func stopSequence() {
        
        displayLink?.invalidate()
        displayLink = nil
        
        autoreverseActiveCount = 1
        queuedTriggers = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
    }
    
    
    @objc private func sequenceCurrentFrame() {
        applyActiveSequenceTriggers()
    }
    
    private func synchronizeRootSequenceTriggers() {
        
        queuedTriggers = sequenceAnimations
        
        for trigger in queuedTriggers {
            if trigger.parent.animationUUID == rootSequenceAnimation?.animationUUID {
                
                if let  index = queuedTriggers.indexOf({$0.parent.animationUUID == rootSequenceAnimation?.animationUUID }) {
                    queuedTriggers[index].parent.animatingLayer     = rootSequenceAnimation?.animatingLayer
                    queuedTriggers[index].parent.reverseAnimation   = rootSequenceAnimation?.reverseAnimation
                    queuedTriggers[index].parent.progessValue       = (rootSequenceAnimation?.progessValue)!
                    queuedTriggers[index].parent.timeRelative     = (rootSequenceAnimation?.timeRelative)!
                    queuedTriggers[index].parent.sequenceDelegate   = rootSequenceAnimation?.sequenceDelegate
                }
            }
        }
    }
    
    private func applyActiveSequenceTriggers(forceAnimation : Bool = false) {
        
        for trigger in queuedTriggers {
            if shouldTriggerRelativeTo(trigger.child, parent : trigger.parent, forceAnimation : forceAnimation) {
                
                trigger.child.applyFinalState(true)
                
                queuedTriggers = queuedTriggers.filter {
                    !($0.child.animationUUID == trigger.child.animationUUID &&
                        $0.parent.animationUUID == trigger.parent.animationUUID)
                }
            }
        }
        
        if queuedTriggers.count == 0 && autoreverse == true && autoreverseActiveCount <= autoreverseCount * 2 {
            reverseSequenceIfNeeded()
        } else if queuedTriggers.count == 0 {
            stopSequence()
        }
    }
    
    
    private func shouldTriggerRelativeTo(child : FASequenceAnimatable,
                                         parent : FASequenceAnimatable?,
                                         forceAnimation : Bool = false) -> Bool {
        if parent == nil {
            return true
        }
        
        if let animKey = parent?.animation?.animationUUID,
               animationgLayer = parent?.animation?.animatingLayer,
               runningAnimationGroup = animationgLayer.animationForKey(animKey) as? FAAnimationGroup {
            
            let fireTimeTrigger  = child.timeRelative && runningAnimationGroup.timeProgress() >= child.progessValue
            let fireValueTrigger = child.timeRelative == false && runningAnimationGroup.valueProgress() >= child.progessValue
            
            if fireTimeTrigger || fireValueTrigger || forceAnimation  {
                return true
            }
        }
        
        return false
    }
}


// MARK: - Auto Reverse Logic

public extension FASequence {
    
    func reverseSequenceIfNeeded() {
        
        var startAutoReverse = true
        
        if queuedTriggers.count == 0 {
            for trigger in sequenceAnimations {
                if let animation = trigger.child.animation as? FAAnimationGroup {
                    if animation.timeProgress() < 1.0 {
                        startAutoReverse = false
                    }
                }
            }
            
            if let animation = rootSequenceAnimation?.animation as? FAAnimationGroup {
                if animation.timeProgress() < 1.0 {
                    startAutoReverse = false
                }
            }
        }
        
        if startAutoReverse == false {  return }
        
        if self.autoreverseActiveCount >= self.autoreverseCount * 2 {
            stopSequence()
            
            rootSequenceAnimation = rootSequenceAnimation!.reverseAnimation
            
            var newSequenceAnimations  = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
            
            for trigger in sequenceAnimations {
                newSequenceAnimations.append((parent : trigger.parent.reverseAnimation! , child : trigger.child.reverseAnimation!))
            }
            
            sequenceAnimations = newSequenceAnimations
            return
        }
        
        autoreverseActiveCount = autoreverseActiveCount + 1
        rootSequenceAnimation = rootSequenceAnimation!.reverseAnimation
        
        var newSequenceAnimations  = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
        
        for trigger in sequenceAnimations {
            newSequenceAnimations.append((parent : trigger.parent.reverseAnimation! , child : trigger.child.reverseAnimation!))
        }
        
        sequenceAnimations = newSequenceAnimations
        queuedTriggers = newSequenceAnimations
        
        rootSequenceAnimation?.applyFinalState(true)
    }

}
// if let view =  weakLayer?.owningView() {
//      let progressDelay = max(0.0 , _autoreverseDelay/duration)
//       configureAnimationTrigger(animationGroup, onView: view, atTimeProgress : 1.0 + CGFloat(progressDelay))
//  }

