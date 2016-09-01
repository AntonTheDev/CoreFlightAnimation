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
        
        
        if delaySegnmentedControl.selectedSegmentIndex == 0 {
            selectedDelaySegment = delaySegnmentedControl.selectedSegmentIndex
           
            var adjustedPosition = enableSecondaryViewLabel.center
            adjustedPosition.y =  adjustedPosition.y + 16
            
            let hiddenAlphaAnimation = FABasicAnimation(keyPath: "opacity")
            hiddenAlphaAnimation.easingFunction = .OutSine
            hiddenAlphaAnimation.toValue = 0.0
            hiddenAlphaAnimation.duration = 0.5
           
            let secondaryViewLabelPositionaAnimation = FABasicAnimation(keyPath: "position")
            secondaryViewLabelPositionaAnimation.easingFunction = .OutSine
            secondaryViewLabelPositionaAnimation.toValue = NSValue(CGPoint: adjustedPosition)
            secondaryViewLabelPositionaAnimation.duration = 0.5

            let sequence = FASequence(onView: atProgressLabel, withAnimation: hiddenAlphaAnimation)
            
            sequence.addSequenceFrameFrame(withAnimation: hiddenAlphaAnimation,
                                          onView: progressLabel,
                                           atProgress: 0.0)
            
            sequence.addSequenceFrameFrame(withAnimation: secondaryViewLabelPositionaAnimation,
                                           onView: enableSecondaryViewLabel,
                                           atProgress: 0.0)
        
            sequence.addSequenceFrameFrame(withAnimation: hiddenAlphaAnimation,
                                           onView: progressTriggerSlider,
                                           atProgress: 0.0)
            
            sequence.startSequence()
            
        } else if delaySegnmentedControl.selectedSegmentIndex != 0  {
           
            selectedDelaySegment = delaySegnmentedControl.selectedSegmentIndex
            
            let showAlphaAnimation = FABasicAnimation(keyPath: "opacity")
            showAlphaAnimation.easingFunction = .OutSine
            showAlphaAnimation.toValue = 1.0
            showAlphaAnimation.duration = 0.5
      
            let secondaryViewLabelPositionaAnimation = FABasicAnimation(keyPath: "position")
            secondaryViewLabelPositionaAnimation.easingFunction = .OutSine
            secondaryViewLabelPositionaAnimation.toValue = NSValue(CGPoint: initialCenter)
            secondaryViewLabelPositionaAnimation.duration = 0.5
            
            
            let sequence = FASequence(onView: atProgressLabel, withAnimation: showAlphaAnimation)
            
            sequence.addSequenceFrameFrame(withAnimation: showAlphaAnimation,
                                           onView: progressLabel,
                                           atProgress: 0.1)
            
            sequence.addSequenceFrameFrame(withAnimation: secondaryViewLabelPositionaAnimation,
                                           onView: enableSecondaryViewLabel,
                                           atProgress: 0.5)
            
            sequence.addSequenceFrameFrame(withAnimation: showAlphaAnimation,
                                           onView: progressTriggerSlider,
                                           atProgress: 0.1)
            
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