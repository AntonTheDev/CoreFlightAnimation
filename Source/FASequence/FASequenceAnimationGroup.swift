//
//  FASequenceAnimationGroup.swift
//  CoreFlightAnimation
//
//  Created by Anton Doudarev on 9/9/16.
//
//

import Foundation
import UIKit

public class FASequenceAnimationGroup : CAAnimationGroup {
    
    public var animationUUID : String?
    
    public weak var animatingLayer : CALayer? {
        didSet {
            synchronizeSubAnimationLayers()
        }
    }
    
    public var startTime : CFTimeInterval?  {
        didSet {
            synchronizeSubAnimationStartTime()
        }
    }
    
    public weak var sequenceDelegate    : FASequenceDelegate?
    
    public var timeRelative = true
    public var progessValue : CGFloat = 0.0
    public var triggerOnRemoval : Bool = false
    
    public var autoreverse : Bool = false
    public var autoreverseCount: Int = 1
    public var autoreverseDelay: NSTimeInterval = 1.0
    public var autoreverseInvertEasing : Bool = false
    public var autoreverseInvertProgress : Bool = false
    
    public var reverseAnimation : FASequenceAnimatable?
    internal weak var primaryAnimation : FABasicAnimation?
    
    deinit {
        reverseAnimation = nil
        print("DEINIT GROUP")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        
        let sequenceAnimation = super.copyWithZone(zone) as! FASequenceAnimationGroup
        
        sequenceAnimation.animationUUID                 = animationUUID
        sequenceAnimation.animatingLayer                = animatingLayer
        sequenceAnimation.startTime                     = startTime
        
        sequenceAnimation.sequenceDelegate              = sequenceDelegate
        sequenceAnimation.timeRelative                  = timeRelative
        sequenceAnimation.progessValue                  = progessValue
        sequenceAnimation.triggerOnRemoval              = triggerOnRemoval
        
        sequenceAnimation.autoreverse                   = autoreverse
        sequenceAnimation.autoreverseCount              = autoreverseCount
        sequenceAnimation.autoreverseDelay              = autoreverseDelay
        sequenceAnimation.autoreverseInvertEasing       = autoreverseInvertEasing
        sequenceAnimation.autoreverseInvertProgress     = autoreverseInvertProgress
        sequenceAnimation.duration                      = duration
        
        sequenceAnimation.reverseAnimation              = reverseAnimation
        
        return sequenceAnimation
    }
    
    required public override init() {
        super.init()
        animationUUID = String(NSUUID().UUIDString)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Called by the didSet observer of the animatingLayer, ensures
     that all the sub animations have their layer set for synchronization
     */
    func synchronizeSubAnimationLayers() {
        
        primaryAnimation?.animatingLayer = animatingLayer
        
        if let currentAnimations = animations {
            for animation in currentAnimations {
                if let customAnimation = animation as? FABasicAnimation {
                    customAnimation.animatingLayer = animatingLayer
                }
            }
        }
    }
    
    /**
     Called by the didSet observer of the startTime, ensures
     that all the sub animations have a synchromous startTime
     for calculating progress
     */
    func synchronizeSubAnimationStartTime() {
        
        primaryAnimation?.startTime = startTime
        
        if let currentAnimations = animations {
            for animation in currentAnimations {
                if let customAnimation = animation as? FABasicAnimation {
                    customAnimation.startTime = startTime
                }
            }
        }
    }
}

extension FAAnimationGroup : FASequenceAnimatable {
    
    public func sequenceCopy() -> FASequenceAnimatable {
        return self.copy() as! FASequenceAnimatable
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
    
    private func configuredSequenceCopy(child : FASequenceAnimatable,
                                        onView view: UIView,
                                               progress : CGFloat = 0.0,
                                               timeRelative : Bool = true) -> FASequenceTrigger? {
        
        let sequence = child.sequenceCopy()
        
        sequence.animatingLayer = view.layer
        sequence.progessValue = progress
        sequence.timeRelative = timeRelative
        sequence.sequenceDelegate = sequenceDelegate
        
        return sequenceDelegate?.appendSequenceAnimation(sequence, relativeTo : self)
    }
    
    public func applyFinalState(animated : Bool = false) {
        
        if let animatingLayer = animatingLayer {
            if animated {
                animatingLayer.speed = 1.0
                animatingLayer.timeOffset = 0.0
                
                if let animationUUID = animationUUID {
                    startTime = animatingLayer.convertTime(CACurrentMediaTime(), fromLayer: nil)
                    animatingLayer.addAnimation(self, forKey: animationUUID)
                }
            }
            
            if let subAnimations = animations {
                for animation in subAnimations {
                    if let subAnimation = animation as? FABasicAnimation,
                        let toValue = subAnimation.toValue {
                        
                        if subAnimation.duration <= 0 {
                            return
                        }
                        
                        // print (subAnimation.keyPath, subAnimation.duration)
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