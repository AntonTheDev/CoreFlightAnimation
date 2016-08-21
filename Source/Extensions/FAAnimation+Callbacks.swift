//
//  CAAnimation+Callbacks.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

import Foundation


public typealias FAAnimationDidStart = ((anim: CAAnimation) -> Void)
public typealias FAAnimationDidStop  = ((anim: CAAnimation, complete: Bool) -> Void)

public class FAAnimationDelegate : NSObject {

    var animationDidStart : FAAnimationDidStart?
    var animationDidStop : FAAnimationDidStop?
    
    override public func animationDidStart(anim: CAAnimation) {
        if let startCallback = animationDidStart {
            startCallback(anim : anim)
        }
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let stopCallback = animationDidStop {
            stopCallback(anim : anim, complete: flag)
          
        }
    }
    
    public func setDidStopCallback(stopCallback : FAAnimationDidStop) {
        animationDidStop = stopCallback
    }
    
    public func setDidStartCallback(startCallback : FAAnimationDidStart) {
        animationDidStart = startCallback
    }
}

public extension CAAnimation {
    
    public func setDidStopCallback(stopCallback : FAAnimationDidStop) {
       
        if callbacksSupported() == false {
            print("DidStopCallbacks are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
 
        activeDelegate!.setDidStopCallback { [weak self] (anim, complete) in
            if let _ = self?.delegate as? FAAnimationDelegate {
                stopCallback(anim : anim, complete: complete)
            }
        }
        
        delegate = activeDelegate
    }
    
    public func setDidStartCallback(startCallback : FAAnimationDidStart) {
        
        if callbacksSupported() == false {
            print("DidStartCallback are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        
        activeDelegate!.setDidStartCallback { [weak self] (anim) in
            if let _ = self?.delegate as? FAAnimationDelegate {
                startCallback(anim : anim)
            }
        }
        
        self.delegate = activeDelegate
    }
    
    private func callbacksSupported() -> Bool {
        if let _ = self as? FAAnimationGroup {
        } else if let _ = self as? FABasicAnimation {
        } else{
            return false
        }
        return true
    }
}
