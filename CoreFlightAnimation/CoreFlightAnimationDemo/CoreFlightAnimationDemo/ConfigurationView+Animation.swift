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
 
        let alphaAnimataion = FABasicAnimation(keyPath: "opacity")
        alphaAnimataion.easingFunction = .InOutSine
        alphaAnimataion.toValue = secondaryViewSwitch.enabled ? 1.0 : 0.5
        alphaAnimataion.duration = 0.6
        
        let sequence = FASequenceAnimation(onView: delaySegnmentedControl)
        sequence.startSequence()
        
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

            
            let initialTrigger = FASequenceAnimation(onView: atProgressLabel)
            initialTrigger.animation = alphaAnimataion
            
            let backgroundTrigger = FASequenceAnimation(onView: enableSecondaryViewLabel)
            backgroundTrigger.animation = positionAnimation
            backgroundTrigger.progessValue = 0.5
            
            
            let backgroundTrigger2 = FASequenceAnimation(onView: progressTriggerSlider)
            backgroundTrigger2.animation = alphaAnimataion
            backgroundTrigger2.progessValue = 0.5
            
            let sequence = FASequenceGroup()
            sequence.initialTrigger = initialTrigger
            sequence.sequenceAnimations[initialTrigger] = backgroundTrigger
            sequence.sequenceAnimations[backgroundTrigger] = backgroundTrigger2
            
           // configView.cacheAnimation(sequence, forKey: AnimationKeys.ShowConfigAnimation)
            
           
          //  let sequence = FASequenceAnimation(onView: atProgressLabel)
            /*
            let sequenceTrigger = FASequenceAnimation(onView: progressLabel)
            sequenceTrigger.animation = alphaAnimataion
            sequenceTrigger.progessValue = 0.5
            
            let sequenceTrigger2 = FASequenceAnimation(onView: enableSecondaryViewLabel)
            sequenceTrigger2.animation = positionAnimation
            sequenceTrigger2.progessValue = 0.5
        
            
            let sequenceTrigger3 = FASequenceAnimation(onView: progressTriggerSlider)
            sequenceTrigger3.animation = alphaAnimataion
            sequenceTrigger3.progessValue = 0.5
            */
            /*
            sequence.addSequenceFrame(withAnimation: sequenceTrigger,
                                           onView: progressLabel,
                                           atProgress: 0.0)
            
            sequence.addSequenceFrame(withAnimation: sequenceTrigger2,
                                           onView: enableSecondaryViewLabel,
                                           atProgress: 0.5)
        
            sequence.addSequenceFrame(withAnimation: sequenceTrigger3,
                                           onView: progressTriggerSlider,
                                           atProgress: 0.0)
 
             */
            
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
            
            
            
            let initialTrigger = FASequenceAnimation(onView: progressLabel)
            initialTrigger.animation = alphaAnimataion
            
            let backgroundTrigger = FASequenceAnimation(onView: atProgressLabel)
            backgroundTrigger.animation = alphaAnimataion
            backgroundTrigger.progessValue = 0.5
            
            
            let backgroundTrigger2 = FASequenceAnimation(onView: progressTriggerSlider)
            backgroundTrigger2.animation = alphaAnimataion
            backgroundTrigger2.progessValue = 0.5
            
            let sequence = FASequenceGroup()
            sequence.initialTrigger = initialTrigger
            sequence.sequenceAnimations[initialTrigger] = backgroundTrigger
            sequence.sequenceAnimations[backgroundTrigger] = backgroundTrigger2
            
            
            
            //let sequence = FASequence2()
            
            
            /*
            
            let sequenceTrigger = FASequenceAnimation(onView: progressLabel)
            sequenceTrigger.animation = alphaAnimataion
            sequenceTrigger.progessValue = 0.5
            
            let sequenceTrigger2 = FASequenceAnimation(onView: atProgressLabel)
            sequenceTrigger2.animation = positionAnimation
            sequenceTrigger2.progessValue = 0.5
            
            
            let sequenceTrigger3 = FASequenceAnimation(onView: progressTriggerSlider)
            sequenceTrigger3.animation = alphaAnimataion
            sequenceTrigger3.progessValue = 0.5
            */
            /*
            
            
            sequence.addSequenceFrame(withAnimation: sequenceTrigger,
                                           onView: progressLabel,
                                           atProgress: 0.5)
            
            sequence.addSequenceFrame(withAnimation: sequenceTrigger2,
                                           onView: atProgressLabel,
                                           atProgress: 0.5)
            
            sequence.addSequenceFrame(withAnimation: sequenceTrigger2,
                                           onView: progressTriggerSlider,
                                           atProgress: 0.5)
            */
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