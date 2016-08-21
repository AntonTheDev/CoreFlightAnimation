//
//  CALayer+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

import Foundation


extension CALayer {
    
    final public class func swizzleAddAnimation() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        if self !== CALayer.self {
            return
        }
        
        
        dispatch_once(&Static.token) {
            let originalSelector = #selector(CALayer.addAnimation(_:forKey:))
            let swizzledSelector = #selector(CALayer.FA_addAnimation(_:forKey:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
            
            UIColor.swizzleGetRed()
        }
    }
    
    internal func FA_addAnimation(anim: CAAnimation, forKey key: String?) {
        
        if let animation = anim as? FABasicAnimation {
            let groupRepresentation = animation.groupRepresentation()
            groupRepresentation.synchronizeAnimationGroup(withLayer: self, animationKey : key)
            
            removeAllAnimations()
            FA_addAnimation(groupRepresentation, forKey: key)
            return
        }
        
        guard let animation = anim as? FAAnimationGroup else {
            FA_addAnimation(anim, forKey: key)
            return
        }
        
        animation.synchronizeAnimationGroup(withLayer: self, animationKey : key)
        
        removeAllAnimations()
        FA_addAnimation(animation, forKey: key)
    }
    
    final public func anyValueForKeyPath(keyPath: String) -> Any? {
        if let currentFromValue = self.valueForKeyPath(keyPath) {
            
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
            } else {
                return currentFromValue
            }
        }
        
        return super.valueForKeyPath(keyPath)
    }
    
    final public func owningView() -> View? {
        if let owningView = self.delegate as? View {
            return owningView
        }
        
        return nil
    }
}

extension UIColor {
    
    // This is needed to fix the following radar
    // http://openradar.appspot.com/radar?id=3114410
    
    final public class func swizzleGetRed() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        if self !== CALayer.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = #selector(UIColor.getRed(_:green:blue:alpha:))
            let swizzledSelector = #selector(UIColor.FA_getRed(_:green:blue:alpha:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
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


