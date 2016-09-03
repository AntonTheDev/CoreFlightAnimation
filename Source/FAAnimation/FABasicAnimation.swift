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

public class FABasicAnimation : CAKeyframeAnimation {
    
    public var parentAnimatable : FASequenceAnimatable?
    public var toValue: AnyObject?
    public var fromValue: AnyObject?
    public var easingFunction : FAEasing = .Linear
    public var isPrimary : Bool = false
    
    internal var interpolator : FAInterpolator?
    
    public weak var animatingLayer : CALayer?
    public var animationKey : String?
    public var startTime : CFTimeInterval?
    
    public var autoreverse : Bool = false
    public var autoreverseCount: Int = 1
    public var autoreverseDelay: NSTimeInterval = 1.0
    public var autoreverseEasing: Bool = false
    
    internal var _autoreverseActiveCount: Int = 1
    internal var _autoreverseConfigured: Bool = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInitialValues()
    }
    
    override public init() {
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
       
        animation.animationKey           = animationKey
        animation.animatingLayer         = animatingLayer
        animation.startTime              = startTime
        animation.interpolator           = interpolator

        animation.easingFunction         = easingFunction
        animation.toValue                = toValue
        animation.fromValue              = fromValue
        animation.isPrimary              = isPrimary
        
        animation.autoreverse            = autoreverse
        animation.autoreverseCount       = autoreverseCount
        animation.autoreverseDelay       = autoreverseDelay
        animation.autoreverseEasing    = autoreverseEasing
        
        animation._autoreverseConfigured = _autoreverseConfigured
        animation._autoreverseActiveCount = _autoreverseActiveCount
        
        return animation
    }
    
    final public func configureAnimation(withLayer layer: CALayer?) {
        animatingLayer = layer
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
    
    func synchronize(relativeTo animation : FABasicAnimation? = nil) {

        synchronizeFromValue()
        
        guard let toValue = toValue, fromValue = fromValue else {
            return
        }
    
        interpolator = FAInterpolator(toValue, fromValue, relativeTo : animation?.fromValue)
        
        // adjustSpringVelocityIfNeeded(relativeTo : animation)
        
        let config = interpolator?.interpolatedConfigurationFor(self, relativeTo: animation)
        easingFunction = config!.easing
        duration = config!.duration
        values = config!.values
    }
    
    
    func synchronizeFromValue() {
        
        if let presentationLayer = (animatingLayer?.presentationLayer() as? CALayer),
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
        if let presentationValue = (animatingLayer?.presentationLayer() as? CALayer)?.anyValueForKeyPath(keyPath!),
           let interpolator = interpolator {
                return interpolator.valueProgress(presentationValue)
        }
        
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        let currentTime = animatingLayer?.presentationLayer()!.convertTime(CACurrentMediaTime(), toLayer: nil)
        let difference = currentTime! - startTime!
        
        return CGFloat(round(100 * (difference / duration))/100)
    }
}
