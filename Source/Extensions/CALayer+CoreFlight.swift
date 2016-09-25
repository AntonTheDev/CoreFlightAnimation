//
//  CALayer+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//


import Foundation
import UIKit

public var DebugTriggerLogEnabled = false

internal func swizzleSelector(cls: AnyClass!, originalSelector : Selector, swizzledSelector : Selector) {
    
    let originalMethod = class_getInstanceMethod(cls, originalSelector)
    let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
    
    let didAddMethod = class_addMethod(cls,
                                       originalSelector,
                                       method_getImplementation(swizzledMethod),
                                       method_getTypeEncoding(swizzledMethod))
    if didAddMethod {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
    
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

extension CALayer {
    
    final public class func swizzleAddAnimation() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        if self !== CALayer.self {
            return
        }
        
        dispatch_once(&Static.token) {
            swizzleSelector(self,
                            originalSelector: #selector(CALayer.addAnimation(_:forKey:)),
                            swizzledSelector: #selector(CALayer.FA_addAnimation(_:forKey:)))
            
            swizzleSelector(self,
                            originalSelector: #selector(CALayer.removeAllAnimations),
                            swizzledSelector: #selector(CALayer.FA_removeAllAnimations))
            
            swizzleSelector(self,
                            originalSelector: #selector(CALayer.removeAnimationForKey(_:)),
                            swizzledSelector: #selector(CALayer.FA_removeAnimationForKey(_:)))
            
            UIColor.swizzleGetRed()
        }
    }
    
    
    
    public func addSequence(sequence: FASequence, forKey key: String?) {
        stopRunningSequence()
        sequence.rootSequenceAnimation?.animatingLayer = self
        sequence.rootSequenceAnimation?.startTime = self.convertTime(CACurrentMediaTime(), fromLayer: nil)
        sequence.startSequence()
    }
    
    internal func FA_addAnimation(anim: CAAnimation, forKey key: String?) {
        if let animation = anim as? FAAnimationGroup {
            animation.startTime = self.convertTime(CACurrentMediaTime(), fromLayer: nil)
            animation.synchronizeAnimationGroup(withLayer: self, forKey : key)
            removeAllAnimations()
            FA_addAnimation(anim, forKey: key)
            return
        }
        
        if let animation = anim as? FABasicAnimation {
            if let groupedAnimation = animation.groupedRepresendation() {
                groupedAnimation.startTime = self.convertTime(CACurrentMediaTime(), fromLayer: nil)
                groupedAnimation.synchronizeAnimationGroup(withLayer: self, forKey : key)
                removeAllAnimations()
                FA_addAnimation(groupedAnimation, forKey: key)
            }
            return
        }
        
        removeAllAnimations()
        FA_addAnimation(anim, forKey: key)
      
    }
    internal func FA_removeAnimationForKey(key: String) {
        stopSequenceForKey(key)
        FA_removeAnimationForKey(key)
    }
    
    internal func FA_removeAllAnimations() {
        stopRunningSequence()
        FA_removeAllAnimations()
    }
    
    final private func stopRunningSequence() {
        
        guard let keys = animationKeys() else {
            return
        }
        
        for key in keys {
            stopSequenceForKey(key)
        }
    }
    
    final private func stopSequenceForKey(key : String) {
    
        if let animation = animationForKey(key) as? FAAnimationGroup  {
            animation.sequenceDelegate?.stopSequence()
            if DebugTriggerLogEnabled { print("FASequenceAnimationGroup STOPPED ALL FORKEY ", animation.animationUUID) }
        }
        
        if let animation = animationForKey(key) as? FABasicAnimation  {
            animation.sequenceDelegate?.stopSequence()
            if DebugTriggerLogEnabled { print("FASequenceAnimation STOPPED ALL FORKEY ", animation.animationUUID) }
        }
    }
    
    final public func anyValueForKeyPath(keyPath: String) -> Any? {
        if let currentFromValue = valueForKeyPath(keyPath) {
            
            if let value = typeCastCGColor(currentFromValue) {
                return value
            }
            
            let type = String.fromCString(currentFromValue.objCType) ?? ""
            
            if type.hasPrefix("{CGPoint") {
                return currentFromValue.CGPointValue!
            } else if type.hasPrefix("{CGSize") {
                return currentFromValue.CGSizeValue!
            } else if type.hasPrefix("{CGRect") {
                return currentFromValue.CGRectValue!
            } else if type.hasPrefix("{CATransform3D") {
                return currentFromValue.CATransform3DValue!
            }
            else {
                return currentFromValue
            }
        }
        
        return super.valueForKeyPath(keyPath)
    }
    
    final public func owningView() -> UIView? {
        if let owningView = delegate as? UIView {
            return owningView
        }
        
        return nil
    }
}

extension UIColor {
    
    // This is needed to fix the following radar
    // http://openradar.appspot.com/radar?id=3114410
    
    final internal class func swizzleGetRed() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        if self !== UIColor.self {
            return
        }
        
        dispatch_once(&Static.token) {
            swizzleSelector(self,
                            originalSelector: #selector(UIColor.getRed(_:green:blue:alpha:)),
                            swizzledSelector: #selector(UIColor.FA_getRed(_:green:blue:alpha:)))
        }
    }
    
    internal func FA_getRed(red: UnsafeMutablePointer<CGFloat>,
                            green: UnsafeMutablePointer<CGFloat>,
                            blue: UnsafeMutablePointer<CGFloat>,
                            alpha: UnsafeMutablePointer<CGFloat>) -> Bool {
        
        if CGColorGetNumberOfComponents(self.CGColor) == 4 {
            
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            return  self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
        } else if CGColorGetNumberOfComponents(self.CGColor) == 2 {
            
            var white: CGFloat = 0, whiteAlpha: CGFloat = 0
            
            if self.getWhite(&white, alpha: &whiteAlpha) {
                red.memory = white * 1.0
                green.memory = white * 1.0
                blue.memory = white * 1.0
                alpha.memory = whiteAlpha
                
                return true
            }
        }
        
        return false
    }
}


