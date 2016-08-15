//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public class FABasicAnimation : FASynchronizedAnimation {

    override public init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Final animation value to interpolate to
    public var toValue: AnyObject? {
        get { return _toValue }
        set { _toValue = newValue }
    }
    
    // The easing funtion applied to the duration of the animation
    public var easingFunction : FAEasing  {
        get { return _easingFunction }
        set { _easingFunction = newValue }
    }
    
    // Flag used to track the animation as a primary influencer 
    // for the overall timing within an animation group.
    public var isPrimary : Bool {
        get { return (easingFunction.isSpring() || _isPrimary) }
        set { _isPrimary = newValue }
    }
    
    public func scrubToProgress(progress : CGFloat) {
        weakLayer?.speed = 0.0
        weakLayer?.timeOffset = CFTimeInterval(duration * Double(progress))
    }
}