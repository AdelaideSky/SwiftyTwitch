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
