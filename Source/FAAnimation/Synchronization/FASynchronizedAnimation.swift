//
//  FAAnimation.swift
//  FlightAnimator-Demo
//
//  Created by Anton on 8/13/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public class FASynchronizedAnimation : CAKeyframeAnimation {
    
    internal weak var weakLayer : CALayer?
    
    internal var interpolator : Interpolator?
    internal var _easingFunction : FAEasing = FAEasing.Linear
    
    
    // The start time of the animation,  Used by the springs to find the
    // current velocity in motion
    internal var startTime : CFTimeInterval?
    
    // Auto synchronizes with current presentation layer values
    internal var fromValue: AnyObject?
    internal var _toValue: AnyObject?
    internal var _isPrimary : Bool = false
    
    override public var timingFunction: CAMediaTimingFunction? {
        didSet {
            print("WARMING: FlightAnimator\n Setting timingFunction on an FABasicAnimation has no effect, use the 'easingFunction' property instead\n")
        }
    }
    
    override public init() {
        super.init()
        CALayer.swizzleAddAnimation()
        
        calculationMode = kCAAnimationLinear
        fillMode = kCAFillModeForwards
        removedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        let animation = super.copyWithZone(zone) as! FABasicAnimation
        animation._isPrimary        = _isPrimary
        animation.weakLayer         = weakLayer
        animation.fromValue         = fromValue
        animation.startTime         = startTime
        animation.interpolator      = interpolator
        animation._easingFunction   = _easingFunction
        animation._toValue          = _toValue
        return animation
    }
    
    final public func configureAnimation(withLayer layer: CALayer?) {
        weakLayer = layer
    }
}

internal extension FASynchronizedAnimation {
        
    func synchronize(runningAnimation animation : FABasicAnimation? = nil) {
        configureValues(animation)
    }
    
    func synchronizeAnimationVelocity(fromValue : Any, runningAnimation : FABasicAnimation?) {
        
        if  let presentationLayer = runningAnimation?.weakLayer?.presentationLayer(),
            let animationStartTime = runningAnimation?.startTime,
            let oldInterpolator = runningAnimation?.interpolator {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), toLayer: runningAnimation!.weakLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime) - FAAnimationConfig.AnimationTimeAdjustment
            
            if _easingFunction.isSpring() {
                _easingFunction = oldInterpolator.adjustedEasingVelocity(deltaTime, easingFunction: _easingFunction)
            }
            
        } else {
            switch _easingFunction {
            case .SpringDecay(_):
                _easingFunction =  FAEasing.SpringDecay(velocity: interpolator?.zeroVelocityValue())
                
            case let .SpringCustom(_,frequency,damping):
                _easingFunction = FAEasing.SpringCustom(velocity: interpolator?.zeroVelocityValue() ,
                                                       frequency: frequency,
                                                       ratio: damping)
            default:
                break
            }
        }
    }
    
    func configureValues(runningAnimation : FABasicAnimation? = nil) {
        if let presentationLayer = (weakLayer?.presentationLayer() as? CALayer),
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
            
            synchronizeAnimationVelocity(fromValue, runningAnimation: runningAnimation)
            
            if let _toValue = _toValue,
                let fromValue = fromValue {
                
                interpolator  = Interpolator(toValue: _toValue,
                                             fromValue: fromValue,
                                             previousValue : runningAnimation?.fromValue)
                
                let config = interpolator?.interpolatedConfiguration(CGFloat(duration), easingFunction: _easingFunction)
                
                duration = config!.duration
                values = config!.values
            }
        }
    }
}


internal extension FASynchronizedAnimation {
    
    func valueProgress() -> CGFloat {
        if let presentationValue = (weakLayer?.presentationLayer() as? CALayer)?.anyValueForKeyPath(keyPath!) {
            return interpolator!.valueProgress(presentationValue)
        }
        
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        let currentTime = weakLayer?.presentationLayer()!.convertTime(CACurrentMediaTime(), toLayer: nil)
        let difference = currentTime! - startTime!
        
        return CGFloat(round(100 * (difference / duration))/100)
    }
}
