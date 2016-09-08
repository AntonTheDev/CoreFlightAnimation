//
//  ConfigurationView+Animation.swift
//  CoreFlightAnimationDemo
//
//  Created by Anton on 8/31/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import CoreFlightAnimation

extension ConfigurationView {
    
    func updateProgressEnabledAnimation() {
 
        let alphaAnimation = FABasicAnimation(keyPath: "opacity")
        alphaAnimation.easingFunction = .InOutSine
        alphaAnimation.toValue = secondaryViewSwitch.enabled ? 1.0 : 0.5
        alphaAnimation.duration = 0.6
        
        let alphaTrigger = FASequenceAnimation(onView: delaySegnmentedControl)
        alphaTrigger.animation = alphaAnimation
    
        alphaTrigger.startSequence()
    }

    func updateAnimation() {
        
        if delaySegnmentedControl.selectedSegmentIndex == 0 {
            selectedDelaySegment = delaySegnmentedControl.selectedSegmentIndex
        
            let alphaAnimataion = FABasicAnimation(keyPath: "opacity")
            alphaAnimataion.easingFunction = .InOutSine
            alphaAnimataion.toValue = 0.0
            alphaAnimataion.duration = 0.5
           
            let positionAnimation = FABasicAnimation(keyPath: "position")
            positionAnimation.easingFunction = .InOutSine
            positionAnimation.toValue = NSValue(CGPoint: adjustedPosition)
            positionAnimation.duration = 0.5

    
            let progressLabelTrigger = FASequenceAnimation(onView: progressLabel)
            progressLabelTrigger.animation = alphaAnimataion
            
            let atProgressLabelTrigger = FASequenceAnimation(onView: atProgressLabel)
            atProgressLabelTrigger.animation = alphaAnimataion
            atProgressLabelTrigger.progessValue = 0.0
            
            let progressTriggerSliderTrigger = FASequenceAnimation(onView: progressTriggerSlider)
            progressTriggerSliderTrigger.animation = alphaAnimataion
            progressTriggerSliderTrigger.progessValue = 0.0
            

            let titleLabelTrigger = FASequenceAnimation(onView: enableSecondaryViewLabel)
            titleLabelTrigger.animation = positionAnimation
            titleLabelTrigger.progessValue = 0.5
            
            
            let sequence = FASequenceAnimationGroup()
            sequence.animation = progressLabelTrigger
            
            sequence.appendSequenceAnimation(progressTriggerSliderTrigger, relativeTo : progressLabelTrigger)
            sequence.appendSequenceAnimation(atProgressLabelTrigger, relativeTo : progressLabelTrigger)
            sequence.appendSequenceAnimation(titleLabelTrigger, relativeTo : progressLabelTrigger)
            
            sequence.startSequence()
            
        } else if delaySegnmentedControl.selectedSegmentIndex != 0  {
           
            selectedDelaySegment = delaySegnmentedControl.selectedSegmentIndex
            
            let alphaAnimataion = FABasicAnimation(keyPath: "opacity")
            alphaAnimataion.easingFunction = .InOutSine
            alphaAnimataion.toValue = 1.0
            alphaAnimataion.duration = 0.5
      
            let positionAnimation = FABasicAnimation(keyPath: "position")
            positionAnimation.easingFunction = .InOutSine
            positionAnimation.toValue = NSValue(CGPoint: initialCenter)
            positionAnimation.duration = 0.5
            
            
            let titleLabelTrigger = FASequenceAnimation(onView: enableSecondaryViewLabel)
            titleLabelTrigger.animation = positionAnimation
            
            let progressLabelTrigger = FASequenceAnimation(onView: progressLabel)
            progressLabelTrigger.animation = alphaAnimataion
            progressLabelTrigger.progessValue = 0.5
            
            let atProgressLabelTrigger = FASequenceAnimation(onView: atProgressLabel)
            atProgressLabelTrigger.animation = alphaAnimataion
            atProgressLabelTrigger.progessValue = 0.0
            
            let progressTriggerSliderTrigger = FASequenceAnimation(onView: progressTriggerSlider)
            progressTriggerSliderTrigger.animation = alphaAnimataion
            progressTriggerSliderTrigger.progessValue = 0.0
            
            let sequence = FASequenceAnimationGroup()
            sequence.animation = titleLabelTrigger
            
            sequence.appendSequenceAnimation(progressLabelTrigger, relativeTo : titleLabelTrigger)
            sequence.appendSequenceAnimation(atProgressLabelTrigger, relativeTo : progressLabelTrigger)
            sequence.appendSequenceAnimation(progressTriggerSliderTrigger, relativeTo : progressLabelTrigger)
         
            sequence.startSequence()
 
            if selectedDelaySegment == 1 {
                atProgressLabel.text = "Trigger @ Time Progress:  "
            } else {
                atProgressLabel.text = "Trigger @ Value Progress: "
            }
        }
    
        interactionDelegate?.didUpdateTriggerType(selectedDelaySegment)
    }
}