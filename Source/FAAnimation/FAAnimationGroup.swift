//
//  FAAnimationGroup.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

/**
 The timing priority effect how the time is resynchronized across the animation group.
 If the FAAnimation is marked as primary
 
 - MaxTime: <#MaxTime description#>
 - MinTime: <#MinTime description#>
 - Median:  <#Median description#>
 - Average: <#Average description#>
 */
public enum FAPrimaryTimingPriority : Int {
    case MaxTime
    case MinTime
    case Median
    case Average
}

public class FAAnimationGroup : FASynchronizedGroup {
    
    override public init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var primaryTimingPriority : FAPrimaryTimingPriority  {
        get { return _primaryTimingPriority }
        set { _primaryTimingPriority = newValue }
    }
    
    public func scrubToProgress(progress : CGFloat) {
        weakLayer?.speed = 0.0
        weakLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
    }
    
    
    public func triggerAnimation(animation : AnyObject,
                          onView view : UIView,
                          atTimeProgress timeProgress: CGFloat? = nil,
                          atValueProgress valueProgress: CGFloat? = nil) {
        
        attachTrigger(animation,
                     onView : view,
                     atTimeProgress : timeProgress,
                     atValueProgress : valueProgress)
    }
}

//MARK: Public API

extension FAAnimationGroup {

    public func applyFinalState(animated : Bool = true) {
        // stopTriggerTimer()
        
        if let animationLayer = weakLayer {
            if animated {
                animationLayer.speed = 1.0
                animationLayer.timeOffset = 0.0
                
                if animationKey == nil {
                    animationKey =  String(NSUUID().UUIDString)
                }
            
                startTime = animationLayer.convertTime(CACurrentMediaTime(), fromLayer: nil)
                animationLayer.addAnimation(self, forKey: animationKey)
                startTriggerTimer()
            }
            
            if let subAnimations = animations {
                for animation in subAnimations {
                    if let subAnimation = animation as? FABasicAnimation,
                        let toValue = subAnimation.toValue {
                        
                        //TODO: Figure out why the opacity is not reflected on the UIView
                        //All properties work correctly, but to ensure that the opacity is reflected
                        //I am setting the alpha on the UIView itsel ?? WTF
                        if subAnimation.keyPath! == "opacity" {
                            animationLayer.owningView()!.setValue(toValue, forKeyPath: "alpha")
                        } else {
                            animationLayer.setValue(toValue, forKeyPath: subAnimation.keyPath!)
                        }
                    }
                }
            }
        }
    }
}