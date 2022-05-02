//
//  UIHelpers.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 01/05/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import SwiftUI

// Not sure how I feel about extending CGFloat in this way
// Consder it an experiment
extension CGFloat {
    static func padding(_ multiplier: CGFloat) -> CGFloat {
        return 8 * multiplier
    }
    
    static var cornerRadius: CGFloat { return 8 }
    static var strokeWidth: CGFloat { return 2 }
}
