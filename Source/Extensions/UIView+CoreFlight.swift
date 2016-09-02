//
//  UIView+AnimationCache.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 6/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit


private struct FAAssociatedKey {
    static var layoutConfigurations = "layoutConfigurations"
}


public var cachedSequences = [String : FAAnimationSequence]()

public extension UIView {
    
    public func applyCachedAnimation(forKey key: String) {
        if let sequence = cachedSequences[key]  {
            sequence.startSequence()
        }
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