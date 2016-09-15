//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

//MARK: - FABasicAnimation

public class FABasicAnimation : FASequenceAnimation {
    
    public var toValue: AnyObject?
    public var fromValue: AnyObject?
    
    public var easingFunction : FAEasing = .Linear
    public var isPrimary : Bool = false
    
    internal var interpolator : FAInterpolator?
    
    public var animation : FASequenceAnimatable? {
        get { return self }
        set { }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInitialValues()
    }
    
    required public init() {
        super.init()
        initializeInitialValues()
    }
    
    public convenience init(keyPath path: String?) {
        self.init()
        keyPath = path
        initializeInitialValues()
    }
    
    internal func initializeInitialValues() {
        CALayer.swizzleAddAnimation()
        
        calculationMode = kCAAnimationLinear
        fillMode = kCAFillModeForwards
        removedOnCompletion = true
        values = [AnyObject]()
    }

    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animation = super.copyWithZone(zone) as! FABasicAnimation
       
        animation.toValue                   = toValue
        animation.fromValue                 = fromValue
        animation.easingFunction            = easingFunction
        animation.isPrimary                 = isPrimary
   
        animation.interpolator              = interpolator
        return animation
    }
    
    public func groupedRepresendation() -> FAAnimationGroup? {
        
        let groupedAnimation = FAAnimationGroup()
        
        groupedAnimation.sequenceDelegate              = sequenceDelegate
        
        groupedAnimation.animations = [self]
        groupedAnimation.animationUUID                = animationUUID!
        groupedAnimation.animatingLayer               = animatingLayer
        
        groupedAnimation.progessValue                 = progessValue
        groupedAnimation.timeRelative                  = timeRelative
        groupedAnimation.progessValue                  = progessValue
        groupedAnimation.triggerOnRemoval              = triggerOnRemoval
        
        groupedAnimation.autoreverse                  = autoreverse
        groupedAnimation.autoreverseCount             = autoreverseCount
        groupedAnimation.autoreverseDelay             = autoreverseDelay
        groupedAnimation.autoreverseInvertEasing      = autoreverseInvertEasing
        groupedAnimation.autoreverseInvertProgress    = autoreverseInvertProgress
        
        groupedAnimation.startTime                     = startTime
        groupedAnimation.duration                      = duration
        
        groupedAnimation.reverseAnimation              = (reverseAnimation as? FABasicAnimation)?.groupedRepresendation()
        
        
        return groupedAnimation
    }
    
    
    /// Not Ready for Prime Time, being declared as private
    /// Adjusts animation based on the progress form 0 - 1
    
    /*
     private func scrubToProgress(progress : CGFloat) {
     animatingLayer?.speed = 0.0
     animatingLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
     }
     */
}

//MARK: - Synchronization Logic

internal extension FABasicAnimation {
    
    internal func synchronize(relativeTo animation : FABasicAnimation? = nil) {

        synchronizeFromValue()
        
        guard let toValue = toValue, let fromValue = fromValue else {
            return
        }
    
        interpolator = FAInterpolator(toValue, fromValue, relativeTo : animation?.fromValue)
    
        let config = interpolator?.interpolatedConfigurationFor(self, relativeTo: animation)
        easingFunction = config!.easing
        duration = config!.duration
        values = config!.values
        
        let newAnimation = sequenceCopy()  as! FABasicAnimation
        
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
    
    internal func synchronizeFromValue() {

      //  guard fromValue == nil else {
      //      return
      //  }
        
        if let presentationLayerObject = animatingLayer?.presentationLayer(),
            let presentationLayer = presentationLayerObject as? CALayer,
            let presentationValue = presentationLayer.anyValueForKeyPath(keyPath!) {
            
            if let currentValue = presentationValue as? CGPoint {
                fromValue = NSValue(CGPoint : currentValue)
            } else  if let currentValue = presentationValue as? CGSize {
                fromValue = NSValue(CGSize : currentValue)
            } else  if let currentValue = presentationValue as? CGRect {
                fromValue = NSValue(CGRect : currentValue)
            } else  if let currentValue = presentationValue as? CGFloat {
                fromValue = NSNumber(float : Float(currentValue))
            } else  if let currentValue = presentationValue as? CATransform3D {
                fromValue = NSValue(CATransform3D : currentValue)
            } else if let currentValue = typeCastCGColor(presentationValue) {
                fromValue = currentValue
            }
        }
    }

    func adjustSpringVelocityIfNeeded(relativeTo animation : FABasicAnimation?) {
        
        guard easingFunction.isSpring() == true else {
            return
        }
        
        if easingFunction.isSpring() {
            if let adjustedEasing = interpolator?.adjustedVelocitySpring(easingFunction, relativeTo : animation) {
                easingFunction = adjustedEasing
            }
        }
    }
    
    internal func convertTimingFunction() {
        
        print("timingFunction has no effect, converting to 'easingFunction' property\n")
        
        switch timingFunction?.valueForKey("name") as! String {
        case kCAMediaTimingFunctionEaseIn:
            easingFunction = .InCubic
        case kCAMediaTimingFunctionEaseOut:
            easingFunction = .OutCubic
        case kCAMediaTimingFunctionEaseInEaseOut:
            easingFunction = .InOutCubic
        default:
            easingFunction = .SmoothStep
        }
    }
}


//MARK: - Animation Progress Values

internal extension FABasicAnimation {
    
    func valueProgress() -> CGFloat {
        
        if let presentationLayerObject = animatingLayer?.presentationLayer(),
            let presentationLayer = presentationLayerObject as? CALayer,
            let presentationValue = presentationLayer.anyValueForKeyPath(keyPath!),
            let interpolator = interpolator {
            
                return interpolator.valueProgress(presentationValue)
        }
        
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        if let presentationLayer = animatingLayer?.presentationLayer() {
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: nil)
            let difference = currentTime - startTime!
            
            return CGFloat(round(100 * (difference / duration))/100)
        }
        
        return 0.0
    }
}
