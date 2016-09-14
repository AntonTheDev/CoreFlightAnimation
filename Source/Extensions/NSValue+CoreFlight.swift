//
//  NSValue+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

extension NSValue {    
   
    final public func typeValue() -> Any? {
        var type : NSString = ""
        
        autoreleasepool {
            type = NSString(UTF8String: objCType) ?? ""
        }
        
        if type.hasPrefix("{CGPoint") {
            return self.CGPointValue()
        } else if type.hasPrefix("{CGSize") {
            return self.CGSizeValue()
        } else if type.hasPrefix("{CGRect") {
            return self.CGRectValue()
        } else if type.hasPrefix("{CATransform3D") {
            return self.CATransform3DValue
        } else {
            return self
        }

    }
}




