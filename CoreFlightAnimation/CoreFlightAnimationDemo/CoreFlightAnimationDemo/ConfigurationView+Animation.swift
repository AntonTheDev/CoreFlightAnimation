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
    
    func updateProgressEnabledAnimation() {
 
        let alphaAnimataion = FABasicAnimation(keyPath: "opacity")
        alphaAnimataion.easingFunction = .InOutSine
        alphaAnimataion.toValue = secondaryViewSwitch.enabled ? 1.0 : 0.5
        alphaAnimataion.duration = 0.6
        
        let sequence = FASequence(onView: delaySegnmentedControl, withAnimation: alphaAnimataion)
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

            let sequence = FASequence(onView: atProgressLabel, withAnimation: alphaAnimataion)
            
            sequence.addSequenceFrame(withAnimation: alphaAnimataion,
                                           onView: progressLabel,
                                           atProgress: 0.0)
            
            sequence.addSequenceFrame(withAnimation: positionAnimation,
                                           onView: enableSecondaryViewLabel,
                                           atProgress: 0.5)
        
            sequence.addSequenceFrame(withAnimation: alphaAnimataion,
                                           onView: progressTriggerSlider,
                                           atProgress: 0.0)
            
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
            
            let sequence = FASequence(onView: enableSecondaryViewLabel, withAnimation: positionAnimation)
            
            sequence.addSequenceFrame(withAnimation: alphaAnimataion,
                                           onView: progressLabel,
                                           atProgress: 0.5)
            
            sequence.addSequenceFrame(withAnimation: alphaAnimataion,
                                           onView: atProgressLabel,
                                           atProgress: 0.5)
            
            sequence.addSequenceFrame(withAnimation: alphaAnimataion,
                                           onView: progressTriggerSlider,
                                           atProgress: 0.5)
            
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