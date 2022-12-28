//
//  IntFormatter.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 27/12/2022.
//

import Foundation

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
}
extension Int {
    var customFormatted: String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""

        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(String(format: "%g", formatted))B"

        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(String(format: "%g", formatted))M"

        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(String(format: "%g", formatted))K"

        case 0...:
            return "\(self)"

        default:
            return "\(sign)\(self)"
        }
    }

}
