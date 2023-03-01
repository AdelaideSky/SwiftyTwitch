//
//  Date.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI


extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
extension Date {
    var timeAgoDetailDisplay: String {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([ .hour, .minute, .second ], from: self, to: Date())
        let hours = components.hour
        let minutes = components.minute
        let seconds = components.second
        if (minutes ?? 0) > 0 {
            if (hours ?? 0) > 0 {
                return String(format: "%02d:%02d:%02d", hours ?? 0, minutes ?? 0, seconds ?? 0)
            } else {
                return String(format: "00:%02d:%02d", minutes ?? 0, seconds ?? 0)
            }
        } else {
            return String(format: "00:00:%02d", seconds ?? 0)
        }
    }
}
