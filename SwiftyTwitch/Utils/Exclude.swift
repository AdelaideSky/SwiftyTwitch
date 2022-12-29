//
//  Exclude.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI

public extension View {
    @inlinable
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}
