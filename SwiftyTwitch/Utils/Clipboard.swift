//
//  Clipboard.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI

extension String {
    func copy() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(self, forType: .string)
    }
}
