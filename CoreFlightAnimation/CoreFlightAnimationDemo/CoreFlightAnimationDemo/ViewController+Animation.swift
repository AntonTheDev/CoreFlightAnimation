//
//  ViewController+Animation.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 6/13/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

/**
 *  This is used to keep track of the settings in the configuration screen
 */
struct AnimationConfiguration {
    
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    
    var sizeFunction : FAEasing = FAEasing.OutSine
    var positionFunction : FAEasing =  FAEasing.SpringCustom(velocity: CGPointZero, frequency: 14, ratio: 0.8)
    var alphaFunction : FAEasing = FAEasing.InSine
    var transformFunction : FAEasing = FAEasing.OutBack
    
    var positionPrimary : Bool = true
    var sizePrimary : Bool = false
    var alphaPrimary : Bool = false
    var transformPrimary : Bool = false
    
    // For thr purpose of the example
    // 0 - Trigger Instantly
    // 1 - Trigger Based on Time Progress
    // 2 - Trigger Based on Value Progress
    var triggerType  : Int = 0
    
    var triggerProgress  : CGFloat = 0
    
    var enableSecondaryView  : Bool = false
    
    static func titleForFunction(function : FAEasing) -> String {
        return functionTypes[functions.indexOf(function)!]
    }
}

/**
 *  These are the keys you register for the animation
 */
struct AnimationKeys {
    
    // The Animation to show and hide the configuration view
    // is toggled by these keys in the example below
    static let ShowConfigAnimation  = "ShowConfigAnimation"
    static let HideConfigAnimation  = "HideConfigAnimation"
    
    // This is the key for the pangesture recogniser that
    // you can flick the view with
    static let PanGestureKey            = "PanGestureKey"
    
    // This key is used to overwrite and sychronize the old
    // animation with the new animation, taking the current position
    // into account
    static let TapStageOneAnimationKey  = "TapStageOneAnimationKey"
    static let TapStageTwoAnimationKey  = "TapStageTwoAnimationKey"
    static let SecondaryAnimationKey    = "SecondaryAnimationKey"
}

let screenBounds = UIScreen.mainScreen().bounds
let openConfigFrame = CGRectMake(20, 20, screenBounds.width - 40, screenBounds.height - 40)
let closedConfigFrame = CGRectMake(20, screenBounds.height + 20, screenBounds.width - 40, screenBounds.height - 40)


//MARK: - Register Animations Example

extension ViewController {
    
    /**
     Called on viewDidLoad, preloads the animation states into memory
     */
    
    func registerConfigViewAnimations() {
        registerShowAnimation()
        registerHideAnimation()
    }
    
    /**
     Register the animations required to show the ConfigView
     */
    
    func registerShowAnimation() {
        
        // Final ConfigView Position and Bounds
        
        let toBounds = CGRectMake(0,0, openConfigFrame.width, openConfigFrame.height)
        let toPosition = CGPointMake(openConfigFrame.midX, openConfigFrame.midY)
        
        // ConfigView Animation Definitions
        
        let boundsAnimation = FABasicAnimation(keyPath: "bounds")
        boundsAnimation.easingFunction = .OutExponential
        boundsAnimation.toValue = NSValue(CGRect: toBounds)
        boundsAnimation.duration = 0.8
        
        let positionAnimation = FABasicAnimation(keyPath: "position")
        positionAnimation.easingFunction = .OutExponential
        positionAnimation.toValue = NSValue(CGPoint: toPosition)
        positionAnimation.duration = 0.8
        positionAnimation.isPrimary = true
        
        
        // BackgroundView Animation Definitions
        
        let alphaAnimation = FABasicAnimation(keyPath: "opacity")
        alphaAnimation.easingFunction = .OutExponential
        alphaAnimation.toValue = 0.5
        alphaAnimation.duration = 0.8
        
        let backgroundColorAnimation = FABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.easingFunction = .Linear
        backgroundColorAnimation.toValue = UIColor.blueColor().CGColor
        backgroundColorAnimation.duration = 0.6
        
        
        // ConfigView AnimationGroup
        
        let configViewAnimationGroup = FAAnimationGroup()
        configViewAnimationGroup.animations = [boundsAnimation, positionAnimation]
        
        
        // BackgroundView AnimationGroup
        
        let backgroundViewAnimationGroup = FAAnimationGroup()
        backgroundViewAnimationGroup.animations = [alphaAnimation, backgroundColorAnimation]
        
        
        // Add Trigger the ConfigView AnimationGroup to apply the
        // backgroundView AnimationGroup on start of the animation
        
        configViewAnimationGroup.triggerAnimation(backgroundViewAnimationGroup, onView: dimmerView)
        
        
        // Register the ConfigView AnimationGroup with the configview to
        // trigger on tap using the defined unique animation key
        
        configView.registerAnimation(animation: configViewAnimationGroup,
                                     forKey: AnimationKeys.ShowConfigAnimation,
                                     timingPriority: animConfig.primaryTimingPriority)
    }
    
    
    /**
     Register the animations required to hide the ConfigView
     */
    
    func registerHideAnimation() {
        
        // Final ConfigView Position and Bounds
        
        let toBounds = CGRectMake(0,0, closedConfigFrame.width, closedConfigFrame.height)
        let toPosition = CGPointMake(closedConfigFrame.midX, closedConfigFrame.midY)
        
        
        // ConfigView Animation Definitions
        
        let boundsAnimation = FABasicAnimation(keyPath: "bounds")
        boundsAnimation.easingFunction = .InOutExponential
        boundsAnimation.toValue = NSValue(CGRect: toBounds)
        boundsAnimation.duration = 0.8
        
        let positionAnimation = FABasicAnimation(keyPath: "position")
        positionAnimation.easingFunction = .InOutExponential
        positionAnimation.toValue = NSValue(CGPoint: toPosition)
        positionAnimation.duration = 0.8
        positionAnimation.isPrimary = true
        
        
        // BackgroundView Animation Definitions
        
        let alphaAnimation = FABasicAnimation(keyPath: "opacity")
        alphaAnimation.easingFunction = .InOutExponential
        alphaAnimation.toValue = 0.0
        alphaAnimation.duration = 0.8
        
        let backgroundColorAnimation = FABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.easingFunction = .Linear
        backgroundColorAnimation.toValue = UIColor.clearColor().CGColor
        backgroundColorAnimation.duration = 0.6
        
        
        // ConfigView AnimationGroup
        
        let configViewAnimationGroup = FAAnimationGroup()
        configViewAnimationGroup.animations = [boundsAnimation, positionAnimation]
        
        
        // BackgroundView AnimationGroup
        
        let backgroundViewAnimationGroup = FAAnimationGroup()
        backgroundViewAnimationGroup.animations = [alphaAnimation, backgroundColorAnimation]
        
        
        // Add Trigger the ConfigView AnimationGroup to apply the
        // backgroundView AnimationGroup on start of the animation
        
        configViewAnimationGroup.triggerAnimation(backgroundViewAnimationGroup, onView: dimmerView)
        
        
        // Register the ConfigView AnimationGroup with the configview to
        // trigger on tap using the defined unique animation key
        
        configView.registerAnimation(animation: configViewAnimationGroup,
                                     forKey: AnimationKeys.HideConfigAnimation,
                                     timingPriority: animConfig.primaryTimingPriority)
    }
    
    func tappedShowConfig() {
        configView.applyAnimation(forKey: AnimationKeys.ShowConfigAnimation)
    }
    
    func tappedCloseConfig() {
        configView.applyAnimation(forKey: AnimationKeys.HideConfigAnimation)
    }
}


//MARK: - Trigger Animation Animation Logic

extension ViewController {
    
    func animateView(toFrame : CGRect,
                     velocity : Any? = nil,
                     transform : CATransform3D = CATransform3DIdentity,
                     toAlpha : CGFloat = 1.0,
                     duration : Double = 0.5,
                     animationKey : String = AnimationKeys.TapStageOneAnimationKey) {
        
      //  guard lastToFrame != toFrame else {
      //      return
      //  }
        
        let toBounds = CGRectMake(0, 0, toFrame.size.width , toFrame.size.height)
        let toPosition = CGCSRectGetCenter(toFrame)
        
        var dragViewViewAnimationGroup = createNewAnimationGroup(toBounds,
                                                           toPosition: toPosition,
                                                           toAlpha: toAlpha,
                                                           toTransform: transform,
                                                           duration: 0.5,
                                                           velocity : velocity,
                                                           animationKey : animationKey)
        
        if animConfig.enableSecondaryView {
            appendTriggerToAnimation(&dragViewViewAnimationGroup)
        }
        
        dragView.layer.addAnimation(dragViewViewAnimationGroup, forKey: animationKey)
        dragView.setFinalAnimationValues()
       // lastToFrame = toFrame
        
    }
    
    func createNewAnimationGroup(toBounds : CGRect,
                           toPosition : CGPoint,
                           toAlpha : CGFloat,
                           toTransform : CATransform3D,
                           duration : Double = 0.5,
                           velocity : Any? = nil,
                           animationKey : String = AnimationKeys.TapStageOneAnimationKey) -> FAAnimationGroup {
        
        var positionAnimationEasing = animConfig.positionFunction
        
        if animationKey == AnimationKeys.PanGestureKey {
           positionAnimationEasing = adjustedEasingCurveForVelocity(velocity)
        }
        
        let boundsAnimation = FABasicAnimation(keyPath: "bounds")
        boundsAnimation.easingFunction = animConfig.sizeFunction
        boundsAnimation.toValue = NSValue(CGRect: toBounds)
        boundsAnimation.duration = duration
        boundsAnimation.isPrimary = animConfig.sizePrimary
        
        let positionAnimation = FABasicAnimation(keyPath: "position")
        positionAnimation.easingFunction = positionAnimationEasing
        positionAnimation.toValue = NSValue(CGPoint: toPosition)
        positionAnimation.duration = duration
        positionAnimation.isPrimary = true
        positionAnimation.isPrimary = animConfig.positionPrimary
        
        let alphaAnimation = FABasicAnimation(keyPath: "opacity")
        alphaAnimation.easingFunction = animConfig.alphaFunction
        alphaAnimation.toValue = toAlpha
        alphaAnimation.duration = duration
        alphaAnimation.isPrimary = animConfig.alphaPrimary
        
        let transformAnimation = FABasicAnimation(keyPath: "transform")
        transformAnimation.easingFunction = animConfig.transformFunction
        transformAnimation.toValue = NSValue(CATransform3D : toTransform)
        transformAnimation.duration = duration
        transformAnimation.isPrimary = animConfig.transformPrimary
        
        let animationGroup = FAAnimationGroup()
        animationGroup.animations = [boundsAnimation, positionAnimation, alphaAnimation, transformAnimation]
        animationGroup.primaryTimingPriority = animConfig.primaryTimingPriority
        animationGroup.autoreverse = true
        animationGroup.autoreverseCount = 2

        return animationGroup
    }
    
    func appendTriggerToAnimation(inout animationgGroup : FAAnimationGroup) {
        
        let currentBounds = CGRectMake(0, 0, lastToFrame.size.width , lastToFrame.size.height)
        let currentPosition = CGCSRectGetCenter(lastToFrame)
        let currentAlpha = self.dragView.alpha
        let currentTransform = self.dragView.layer.transform
        
        let secondaryAnimationGroup = createNewAnimationGroup(currentBounds,
                                                        toPosition: currentPosition,
                                                        toAlpha: currentAlpha,
                                                        toTransform: currentTransform,
                                                        duration: animationgGroup.duration)
        
        switch animConfig.triggerType {
        case 1:
            animationgGroup.triggerAnimation(secondaryAnimationGroup,
                                             onView: dragView2,
                                             atTimeProgress: animConfig.triggerProgress)
        case 2:
            animationgGroup.triggerAnimation(secondaryAnimationGroup,
                                             onView: dragView2,
                                             atValueProgress: animConfig.triggerProgress)
        default:
            animationgGroup.triggerAnimation(secondaryAnimationGroup,
                                             onView: dragView2)
        }
    }
}

//MARK: - Trigger Animation Pan Gesture Example

extension ViewController {
    
    // There is a pan gesture recognizer setup on the dragview
    // Once the gesture recognizer has ended it will take hte current velocity
    // and apply it to the animation if it is using the .Spring or .SpringCustom Curves
    
    func respondToPanRecognizer(recognizer : UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            self.initialCenter = self.dragView.center
            dragView.layer.removeAllAnimations()
        case .Changed:
            let translationPoint = recognizer.translationInView(view)
            var adjustedCenter = self.initialCenter
            adjustedCenter.y += translationPoint.y
            adjustedCenter.x += translationPoint.x
            self.dragView.center = adjustedCenter
        case .Ended:
            let finalFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 240)
            let currentVelocity = recognizer.velocityInView(view)
            animateView(finalFrame,  velocity: currentVelocity, animationKey:  AnimationKeys.PanGestureKey)
        default:
            break
        }
    }
    
    // For the purpose of the Pan Gesture, adjust the velocity on
    // the timing curve for .Spring or .SpringCustom
    // This is called in createNewAnimationGroup(:) only when theanimation key is
    // AnimationKeys.PanGestureKey
    func adjustedEasingCurveForVelocity(velocity : Any? = nil) -> FAEasing {
        
        var positionEasingFunction : FAEasing = animConfig.positionFunction
        
        if velocity != nil {
            switch animConfig.positionFunction {
            case .SpringDecay(_):
                positionEasingFunction = .SpringDecay(velocity: velocity)
            case let .SpringCustom(_, frequency, ratio):
                positionEasingFunction = .SpringCustom(velocity: velocity, frequency: frequency, ratio: ratio)
            default:
                break
            }
        }
        
        return positionEasingFunction
    }
}