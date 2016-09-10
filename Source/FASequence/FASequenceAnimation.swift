//
//  FASequenceTrigger.swift
//  CoreFlightAnimation
//
//  Created by Anton on 9/3/16.
//
//

import Foundation
import UIKit

public class FASequenceAnimation : FABasicAnimation {
    
    public var animationUUID : String?
   
    public weak var sequenceDelegate : FASequenceDelegate?

    public var timeRelative = true
    public var progessValue : CGFloat = 0.0
    public var triggerOnRemoval : Bool = false
    
    public var autoreverse : Bool = false
    public var autoreverseCount: Int = 1
    public var autoreverseDelay: NSTimeInterval = 1.0
    public var autoreverseInvertEasing : Bool = false
    public var autoreverseInvertProgress : Bool = false
    
    public var reverseAnimation : FASequenceAnimatable?
    
    public var animation : FASequenceAnimatable? {
        get { return self }
        set { }
    }
    
    public override var duration: CFTimeInterval {
        didSet {
         //   reverseAnimation?.duration = newValue
        }
    }

    required public override init() {
        super.init()
        animationUUID = String(NSUUID().UUIDString)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        
        let sequenceAnimation = super.copyWithZone(zone) as! FASequenceAnimation
        
        sequenceAnimation.animationUUID             = animationUUID
        
        sequenceAnimation.sequenceDelegate              = sequenceDelegate
        sequenceAnimation.timeRelative                  = timeRelative
        sequenceAnimation.progessValue                  = progessValue
        sequenceAnimation.triggerOnRemoval              = triggerOnRemoval
        
        sequenceAnimation.autoreverse                   = autoreverse
        sequenceAnimation.autoreverseCount              = autoreverseCount
        sequenceAnimation.autoreverseDelay              = autoreverseDelay
        sequenceAnimation.autoreverseInvertEasing        = autoreverseInvertEasing
        sequenceAnimation.autoreverseInvertProgress     = autoreverseInvertProgress
        
        sequenceAnimation.reverseAnimation         = reverseAnimation
       
        return sequenceAnimation
    }
    
    override internal func synchronize(relativeTo animation : FABasicAnimation? = nil) {
        super.synchronize(relativeTo: animation)
  
        let newAnimation = sequenceCopy()  as! FASequenceAnimation
        
        newAnimation.animationUUID              = animationUUID! + "REVERSE"
        newAnimation.values                     = values!.reverse()
        newAnimation.fromValue                  = toValue
        newAnimation.toValue                    = fromValue
    
        newAnimation.autoreverse                = autoreverse
        newAnimation.autoreverseCount           = autoreverseCount
        newAnimation.autoreverseDelay           = autoreverseDelay
        newAnimation.autoreverseInvertEasing     = autoreverseInvertEasing
        newAnimation.autoreverseInvertProgress  = autoreverseInvertProgress
        newAnimation.reverseAnimation           = self
        
        reverseAnimation = newAnimation
    }
}

extension FASequenceAnimation : FASequenceAnimatable {

    public func sequenceCopy() -> FASequenceAnimatable {
        return (self.copy()  as? FASequenceAnimation)!
    }
    
    public func appendSequenceAnimationOnStart(child : FASequenceAnimatable, onView view: UIView) -> FASequenceTrigger? {
        return configuredSequenceCopy(child, onView: view,progress: 0.0, timeRelative: true)
    }
    
    public func appendSequenceAnimation(child : FASequenceAnimatable, onView view: UIView, atProgress progress : CGFloat) -> FASequenceTrigger? {
        return configuredSequenceCopy(child, onView: view, progress: progress, timeRelative: true)
    }
    
    public func appendSequenceAnimation(child : FASequenceAnimatable, onView view: UIView) -> FASequenceTrigger?  {
        return configuredSequenceCopy(child, onView: view, progress: child.progessValue, timeRelative: child.timeRelative)
    }
    
    public func appendSequenceAnimation(child : FASequenceAnimatable, onView view: UIView, atValueProgress progress : CGFloat) -> FASequenceTrigger? {
        return configuredSequenceCopy(child, onView: view, progress: progress, timeRelative: false)
    }
    
    public func applyFinalState(animated : Bool = false) {
        
        let newAnimationGroup = FASequenceAnimationGroup()
        
        newAnimationGroup.animationUUID            = animationUUID
        newAnimationGroup.animatingLayer           = animatingLayer
        newAnimationGroup.startTime                = startTime
        
        newAnimationGroup.autoreverse              = autoreverse
        newAnimationGroup.autoreverseCount         = autoreverseCount
        newAnimationGroup.autoreverseDelay         = autoreverseDelay
        newAnimationGroup.autoreverseInvertEasing         = autoreverseInvertEasing
        newAnimationGroup.autoreverseInvertProgress      = autoreverseInvertProgress
       
        newAnimationGroup.animations = [self]
        
        newAnimationGroup.applyFinalState(animated)
    }
    
    private func configuredSequenceCopy(child : FASequenceAnimatable,
                                        onView view: UIView,
                                        progress : CGFloat = 0.0,
                                        timeRelative : Bool = true) -> FASequenceTrigger? {
        
        let sequence = child.sequenceCopy()
        
        sequence.animatingLayer = view.layer
        sequence.animationUUID = String(NSUUID().UUIDString)
        sequence.progessValue = progress
        sequence.timeRelative = timeRelative
        sequence.sequenceDelegate = sequenceDelegate
       
        return sequenceDelegate?.appendSequenceAnimation(sequence, relativeTo : self)
    }
    
}
