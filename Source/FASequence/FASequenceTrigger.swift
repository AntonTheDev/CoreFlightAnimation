//
//  FASequenceTrigger.swift
//  CoreFlightAnimation
//
//  Created by Anton on 9/3/16.
//
//

import Foundation
import UIKit


public class FASequenceTrigger {
    
    internal weak var parentSequence : FASequence?
    /*
     public var animationKey : String?
     public weak var animatingLayer : CALayer?
     
     public var autoreverse: Bool = false
     public var autoreverseCount: Int  = 1
     public var autoreverseDelay: NSTimeInterval  = 0.31
     public var autoreverseEasing: Bool = false
     */
    internal var parentAnimation : FAAnimationGroup?
    public var triggeredAnimation : FAAnimationGroup!
    
    internal var isTimeRelative = true
    internal var progessValue : CGFloat = 0.0
    internal var triggerOnRemoval : Bool = false
    
    public func addSequenceFrame(withAnimation animation : FASequenceAnimatable,
                                               onView view: UIView,
                                                      relativeToTime timeRelative: Bool = true,
                                                                     atProgress progress : CGFloat = 0.0,
                                                                                triggerOnRemoval : Bool = false) -> FASequenceTrigger {
        
        return parentSequence!.addSequenceFrame(withAnimation : animation,
                                                onView : view,
                                                relativeToTime : timeRelative,
                                                atProgress  : progress,
                                                triggerOnRemoval : triggerOnRemoval,
                                                relativeAnimation : triggeredAnimation)
    }
}
