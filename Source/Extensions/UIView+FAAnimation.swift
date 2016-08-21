//
//  UIView+AnimationCache.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 6/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

import Foundation


private struct FAAssociatedKey {
    static var layoutConfigurations = "layoutConfigurations"
}

public extension UIView {
    
    func registerAnimation(animation animation: Any,
                          forKey key: String,
                          timingPriority : FAPrimaryTimingPriority = .MaxTime) {
        
        if self.cachedAnimations == nil {
            self.cachedAnimations = [NSString : FAAnimationGroup]()
        }
        
        if self.cachedAnimations!.keys.contains(NSString(string: key)) {
            self.cachedAnimations![NSString(string: key)]?.stopTriggerTimer()
            self.cachedAnimations![NSString(string: key)] = nil
        }
        
        if let group = animation as? FAAnimationGroup {
            group.animationKey = key
            group.weakLayer = layer
            group.primaryTimingPriority = timingPriority
            
            cachedAnimations![NSString(string: key)] = group
        } else if let animation = animation as? FABasicAnimation {
            
            let newGroup = FAAnimationGroup()
            newGroup.animationKey = key
            newGroup.weakLayer = layer
            newGroup.primaryTimingPriority = timingPriority
            newGroup.animations = [animation]
            
            cachedAnimations![NSString(string: key)] = newGroup
        }
    }
    /*
    func animate(timingPriority : FAPrimaryTimingPriority = .MaxTime, @noescape animator : (animator : FlightAnimator) -> Void ) {
        let newAnimator = FlightAnimator(withView: self, forKey : "AppliedAnimation",  priority : timingPriority)
        animator(animator : newAnimator)
        applyAnimation(forKey: "AppliedAnimation")
    }
    */
    func setFinalAnimationValues() {
        if let keys = layer.animationKeys() {
            for key in Array(Set(keys)) {
                if let animation = layer.animationForKey(key) as? FAAnimationGroup {
                    animation.startTriggerTimer()
                    animation.applyFinalState(false)
                }
            }
        }
    }
    
    func applyAnimation(forKey key: String,
                               animated : Bool = true) {
        
        if let cachedAnimationsArray = cachedAnimations,
            let animation = cachedAnimationsArray[key] {
            animation.applyFinalState(animated)
        }
    }
    
    func applyAnimationTree(forKey key: String,
                                   animated : Bool = true) {
        
        applyAnimation(forKey : key, animated:  animated)
        applyAnimationsToSubViews(self, forKey: key, animated: animated)
    }
}

public extension UIView {
    
    var cachedAnimations: [NSString : FAAnimationGroup]? {
        get {
            return fa_getAssociatedObject(self, associativeKey: &FAAssociatedKey.layoutConfigurations)
        }
        set {
            if let value = newValue {
                fa_setAssociatedObject(self, value: value, associativeKey: &FAAssociatedKey.layoutConfigurations, policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func fa_setAssociatedObject<T>(object: AnyObject,
                                     value: T,
                                     associativeKey: UnsafePointer<Void>,
                                     policy: objc_AssociationPolicy) {
        
        if let v: AnyObject = value as? AnyObject {
            objc_setAssociatedObject(object, associativeKey, v,  policy)
        } else {
            objc_setAssociatedObject(object, associativeKey, ValueWrapper(value),  policy)
        }
    }
    
    func fa_getAssociatedObject<T>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
        if let v = objc_getAssociatedObject(object, associativeKey) as? T {
            return v
        } else if let v = objc_getAssociatedObject(object, associativeKey) as? ValueWrapper<T> {
            return v.value
        } else {
            return nil
        }
    }
    
    func applyAnimationsToSubViews(inView : UIView, forKey key: String, animated : Bool = true) {
        for subView in inView.subviews {
            subView.applyAnimation(forKey: key, animated: animated)
        }
    }
    
    func appendAnimation(animation : AnyObject, forKey key: String) {
        
        if cachedAnimations == nil {
            cachedAnimations = [NSString : FAAnimationGroup]()
        }
        
        if let newAnimation = animation as? FABasicAnimation {
            
            if let oldAnimation = cachedAnimations![NSString(string: key)] {
                oldAnimation.stopTriggerTimer()
            }
            
            let newAnimationGroup = FAAnimationGroup()
            newAnimationGroup.animations = [newAnimation]
            newAnimationGroup.weakLayer = layer
            cachedAnimations![NSString(string: key)] = newAnimationGroup
        }
        else if let newAnimationGroup = animation as? FAAnimationGroup {
           
            if let oldAnimation = cachedAnimations![key] {
                oldAnimation.stopTriggerTimer()
            }
            
            newAnimationGroup.weakLayer = layer
            cachedAnimations![NSString(string: key)] = newAnimationGroup
        }
    }
}

extension Array where Element : Equatable {
    
    mutating func removeObject(object : Generator.Element) {
        if let index = indexOf(object) {
            removeAtIndex(index)
        }
    }
    
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return filter({$0 as? T == obj}).count > 0
    }
}

final class ValueWrapper<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}