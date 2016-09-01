//
//  ConfigurationView+Animation.swift
//  CoreFlightAnimationDemo
//
//  Created by Anton on 8/31/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension ConfigurationView {
    

    func updateAnimation() {
        /*
        interactionDelegate?.didUpdateTriggerType(segnmentedControl.selectedSegmentIndex)
        
        if delaySegnmentedControl.selectedSegmentIndex == 0 {
            
            var adjustedPosition = enableSecondaryViewLabel.center
            adjustedPosition.y =  adjustedPosition.y + 16
            
            let hiddenAlphaAnimation = FABasicAnimation(keyPath: "alpha")
            hiddenAlphaAnimation.easingFunction = .OutSine
            hiddenAlphaAnimation.toValue = 0.0
            hiddenAlphaAnimation.duration = 0.5
           
            let hiddenProgressLabelAlphaAnimation = FABasicAnimation(keyPath: "alpha")
            hiddenProgressLabelAlphaAnimation.easingFunction = .OutSine
            hiddenProgressLabelAlphaAnimation.toValue = 0.0
            hiddenProgressLabelAlphaAnimation.duration = 0.5
            
            let hiddenProgressTriggerSliderAlphaAnimation = FABasicAnimation(keyPath: "alpha")
            hiddenProgressTriggerSliderAlphaAnimation.easingFunction = .OutSine
            hiddenProgressTriggerSliderAlphaAnimation.toValue = 0.0
            hiddenProgressTriggerSliderAlphaAnimation.duration = 0.5
            
            let secondaryViewLabelPositionaAnimation = FABasicAnimation(keyPath: "position")
            secondaryViewLabelPositionaAnimation.easingFunction = .OutSine
            secondaryViewLabelPositionaAnimation.toValue = NSValue(CGPoint: adjustedPosition)
            secondaryViewLabelPositionaAnimation.duration = 0.5
            
            
            let sequence = FASequence(withStartingAnimation: hiddenAlphaAnimation, onView: self.atProgressLabel)
        
            sequence.trigger(hiddenProgressTriggerSliderAlphaAnimation,
                             onView: self.progressTriggerSlider,
                             atTimeProgress: 0.5,
                             ofAnimation: hiddenAlphaAnimation)
            
        
            sequence.trigger(hiddenProgressTriggerSliderAlphaAnimation,
                             onView: self.enableSecondaryViewLabel,
                             atTimeProgress: 0.2, ofAnimation: hiddenAlphaAnimation)
            
            /*
             atProgressLabel.animate { (animator) in
                animator.alpha(0.0).duration(0.5).easing(.OutSine)
             
                animator.triggerAtTimeProgress(atProgress: 0.01, onView: self.progressLabel, animator: { (animator) in
                    animator.alpha(0.0).duration(0.5).easing(.OutSine)
                })
             
                animator.triggerAtTimeProgress(atProgress: 0.7, onView: self.enableSecondaryViewLabel, animator: { (animator) in
                    animator.position(adjustedPosition).duration(0.5).easing(.InSine)
                })
             
                animator.triggerAtTimeProgress(atProgress: 0.1, onView: self.progressTriggerSlider, animator: { (animator) in
                    animator.alpha(0.0).duration(0.5).easing(.InSine)
                })
             }
             */
        } else  {
            
            let showAlphaAnimation = FABasicAnimation(keyPath: "alpha")
            showAlphaAnimation.easingFunction = .OutSine
            showAlphaAnimation.toValue = 1.0
            showAlphaAnimation.duration = 0.5
      
            
            
            let sequence = FASequence(withStartingAnimation: showAlphaAnimation, onView: enableSecondaryViewLabel)
            
            sequence.trigger(showAlphaAnimation,
                             onView: progressTriggerSlider,
                             atTimeProgress: 0.5,
                             ofAnimation: showAlphaAnimation)
            
            
            sequence.trigger(showAlphaAnimation,
                             onView: progressTriggerSlider,
                             atTimeProgress: 0.5,
                             ofAnimation: showAlphaAnimation)
            
            
            sequence.startSequence()
            
            let sequence3 = FASequence(withStartingAnimation: showAlphaAnimation, onView: progressTriggerSlider)
            
            sequence3.trigger(showAlphaAnimation,
                             onView: dimmerView,
                             atTimeProgress: 0.5,
                             ofAnimation: configViewAnimationGroup)
            
            sequence3.startSequence()
            
            /*
            sequence.trigger(hiddenProgressTriggerSliderAlphaAnimation,
                             onView: self.enableSecondaryViewLabel,
                             atTimeProgress: 0.2, ofAnimation: hiddenAlphaAnimation)
            
            */
            
            /*
             enableSecondaryViewLabel.animate { (animator) in
             animator.position(self.initialCenter).duration(0.5).easing(.OutSine)
             
             animator.triggerAtTimeProgress(atProgress: 0.61, onView: self.atProgressLabel, animator: { (animator) in
             animator.alpha(1.0).duration(0.5).easing(.OutSine)
             })
             
             animator.triggerAtTimeProgress(atProgress: 0.6, onView: self.progressLabel, animator: { (animator) in
             animator.alpha(1.0).duration(0.5).easing(.OutSine)
             })
             
             animator.triggerAtTimeProgress(atProgress: 0.7, onView: self.progressTriggerSlider, animator: { (animator) in
             animator.alpha(1.0).duration(0.5).easing(.OutSine)
             })
             }
             
             if segmentedControl.selectedSegmentIndex == 1 {
             atProgressLabel.text = "Trigger @ Time Progress:  "
             } else {
             atProgressLabel.text = "Trigger @ Value Progress: "
             }
             }
             */
 
 */
        
        //}
    }
}