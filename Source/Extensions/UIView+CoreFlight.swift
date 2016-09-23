//
//  UIView+AnimationCache.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 6/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public var cachedSequences = [String : FASequence]()

public extension UIView {
    
    public func applyCachedAnimation(forKey key: String) {
        if let sequence = cachedSequences[key]  {
            stopRunningSequence()
            sequence.rootSequenceAnimation?.animatingLayer = self.layer
            sequence.rootSequenceAnimation?.startTime = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
            sequence.startSequence()
        }
    }
    
    final private func stopRunningSequence() {
        
        guard let keys = self.layer.animationKeys() else {
            return
        }
        
        for key in keys {
            stopSequenceForKey(key)
        }
    }
    
    final private func stopSequenceForKey(key : String) {
        
        if let animation = self.layer.animationForKey(key) as? FAAnimationGroup  {
            animation.sequenceDelegate?.stopSequence()
            if DebugTriggerLogEnabled { print("FASequenceAnimationGroup STOPPED ALL FORKEY ", animation.animationUUID) }
        }
        
        if let animation = self.layer.animationForKey(key) as? FABasicAnimation  {
            animation.sequenceDelegate?.stopSequence()
            if DebugTriggerLogEnabled { print("FASequenceAnimation STOPPED ALL FORKEY ", animation.animationUUID) }
        }
    }
    
    public func cacheAnimation(animation : FASequence, forKey key: String) {
        cachedSequences[key] = animation
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