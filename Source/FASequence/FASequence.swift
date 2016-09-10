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
    
    var reverseAnimation    : FASequenceAnimatable? { get set }
    
    var animationUUID       : String?   { get set }
    var animatingLayer      : CALayer?  { get set }
    
    var timeRelative        : Bool      { get set }
    var progessValue        : CGFloat   { get set }
    var triggerOnRemoval    : Bool      { get set }
    
    var duration            : NSTimeInterval    { get set }
    
    var autoreverse                 : Bool              { get set }
    var autoreverseCount            : Int               { get set }
    var autoreverseDelay            : NSTimeInterval    { get set }
    var autoreverseInvertEasing      : Bool              { get set }
    var autoreverseInvertProgress   : Bool              { get set }
    
    func applyFinalState(animated : Bool)
    
    func sequenceCopy() -> FASequenceAnimatable
}

public protocol FASequenceTrigger : class {
    
    func appendSequenceAnimationOnStart(child : FASequenceAnimatable,
                                        onView view: UIView) -> FASequenceTrigger?
    
    func appendSequenceAnimation(child : FASequenceAnimatable,
                                 onView view: UIView) -> FASequenceTrigger?
    
    func appendSequenceAnimation(child : FASequenceAnimatable,
                                 onView view: UIView,
                                 atProgress progress : CGFloat) -> FASequenceTrigger?
    
    func appendSequenceAnimation(child : FASequenceAnimatable,
                                 onView view: UIView,
                                 atValueProgress progress : CGFloat) -> FASequenceTrigger?
}

public protocol FASequenceDelegate : FASequenceTrigger {
    
    func appendSequenceAnimation(child : FASequenceAnimatable,
                                 relativeTo parent : FASequenceAnimatable) -> FASequenceTrigger?
    
    func startSequence()
    func stopSequence()
}

public class FASequence : CAAnimation  {
    
    public var rootSequenceAnimation : FASequenceAnimatable? {
        didSet { rootSequenceAnimation?.sequenceDelegate = self }
    }
    
    internal var displayLink : CADisplayLink?

    internal var sequenceAnimations         = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
    internal var queuedSequenceAnimations   = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
    
    
    public var autoreverse: Bool = false
    public var autoreverseCount: Int = 1
    public var autoreverseDelay: NSTimeInterval = 0.0
    public var autoreverseInvertEasing : Bool = false
    public var autoreverseInvertProgress : Bool = false
    
    internal var autoreverseActiveCount: Int = 1
    internal var autoreversePendingDelay: Bool = false
    internal var stopTime : CFTimeInterval?
    
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Sequence State Flags

extension FASequence {
   
    internal var isAnimating : Bool {
        get { return displayLink != nil }
    }
    
    internal var reachedEndOfSequence : Bool {
        get { return (queuedSequenceAnimations.count == 0) }
    }
    
    internal var reversableSequenceInProgress : Bool {
        get { return ( autoreverse == true && autoreverseActiveCount <= autoreverseCount * 2) }
    }
    
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
        
        sequence.animatingLayer           = view.layer
        sequence.animationUUID            = String(NSUUID().UUIDString)
        sequence.progessValue             = progress
        sequence.timeRelative             = timeRelative
        sequence.sequenceDelegate         = self
        
        sequence.autoreverse                = autoreverse
        sequence.autoreverseCount           = autoreverseCount
        sequence.autoreverseDelay           = autoreverseDelay
        sequence.autoreverseInvertEasing     = autoreverseInvertEasing
        sequence.autoreverseInvertProgress  = autoreverseInvertProgress

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
        queuedSequenceAnimations = [(parent : FASequenceAnimatable , child : FASequenceAnimatable)]()
        
        displayLink = nil
        stopTime = nil
        
        autoreverseActiveCount = 1
    }
    
    @objc private func sequenceCurrentFrame() {
        applyActiveSequenceTriggers()
    }
    
    private func synchronizeRootSequenceTriggers() {
        
        queuedSequenceAnimations = sequenceAnimations
        
        for trigger in queuedSequenceAnimations {
            if trigger.parent.animationUUID == rootSequenceAnimation?.animationUUID {
                if let  index = queuedSequenceAnimations.indexOf({$0.parent.animationUUID == rootSequenceAnimation?.animationUUID }) {
                    queuedSequenceAnimations[index].parent.animatingLayer     = rootSequenceAnimation?.animatingLayer
                    queuedSequenceAnimations[index].parent.reverseAnimation   = rootSequenceAnimation?.reverseAnimation
                    queuedSequenceAnimations[index].parent.progessValue       = (rootSequenceAnimation?.progessValue)!
                    queuedSequenceAnimations[index].parent.timeRelative       = (rootSequenceAnimation?.timeRelative)!
                    queuedSequenceAnimations[index].parent.sequenceDelegate   = rootSequenceAnimation?.sequenceDelegate
                }
            }
        }
    }
    
    private func applyActiveSequenceTriggers(forceAnimation : Bool = false) {
        
        for sequenceAnimation in queuedSequenceAnimations {
            if sequenceAnimationActivated(sequenceAnimation, forceAnimation : forceAnimation) {
                removeAnimationFromQueue(sequenceAnimation)
            }
        }
        
        guard reachedEndOfSequence else {
            return
        }
        
        if reversableSequenceInProgress {
            applyReverseSequenceIfNeeded()
        } else {
            stopSequence()
        }
    }
    
    private func sequenceAnimationActivated(sequence: (parent : FASequenceAnimatable , child : FASequenceAnimatable),
                                            forceAnimation force: Bool = false) -> Bool {
        
        if animationShouldActivate(sequence, forceAnimation : force) {
            sequence.child.applyFinalState(true)
            return true
        }
        
        return false
    }
    
    
    private func animationShouldActivate(sequence: (parent : FASequenceAnimatable , child : FASequenceAnimatable),
                                         forceAnimation shouldForceAnimation: Bool = false) -> Bool {
        let child  = sequence.child
        let parent = sequence.parent
        
        if let animKey = parent.animationUUID,
            animationgLayer = parent.animatingLayer,
            runningAnimationGroup = animationgLayer.animationForKey(animKey) as? FAAnimationGroup {
            
            let shouldActivateTimeRelativeAnimation  = child.timeRelative && runningAnimationGroup.timeProgress() >= child.progessValue
            let shouldActivateValueRelativeAnimation = child.timeRelative == false && runningAnimationGroup.valueProgress() >= child.progessValue
            
            if shouldActivateTimeRelativeAnimation || shouldActivateValueRelativeAnimation || shouldForceAnimation  {
                return true
            }
        }
        
        return false
    }
    
    private func removeAnimationFromQueue(sequenceAnimation: (parent : FASequenceAnimatable , child : FASequenceAnimatable)) {
        queuedSequenceAnimations = queuedSequenceAnimations.filter {
            !($0.parent.animationUUID == sequenceAnimation.parent.animationUUID &&
                $0.child.animationUUID == sequenceAnimation.child.animationUUID)
        }
    }
}


// MARK: - Auto Reverse Logic

internal extension FASequence {
    
    internal func applyReverseSequenceIfNeeded() {
  
        var startAutoReverse = true
        
        if queuedSequenceAnimations.count == 0 {
            
            for trigger in sequenceAnimations {
                if let animation = trigger.child as? FAAnimationGroup {
                    if animation.timeProgress() < 1.0 {
                        startAutoReverse = false
                    }
                }
            }
            
            if let animation = rootSequenceAnimation as? FAAnimationGroup {
                if animation.timeProgress() < 1.0 {
                    startAutoReverse = false
                }
            }
        }
        
        if startAutoReverse == false { return }
    
        if autoreverseDelay > 0.0 {
            
            if stopTime == nil {
                stopTime = CFAbsoluteTimeGetCurrent()
            }
            
            let diff =  CFAbsoluteTimeGetCurrent() - stopTime!
            
            if diff < autoreverseDelay {
                return
            }
        }
        
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
        queuedSequenceAnimations = newSequenceAnimations
        rootSequenceAnimation?.applyFinalState(true)
    }
}
// if let view =  weakLayer?.owningView() {
//      let progressDelay = max(0.0 , _autoreverseDelay/duration)
//       configureAnimationTrigger(animationGroup, onView: view, atTimeProgress : 1.0 + CGFloat(progressDelay))
//  }

