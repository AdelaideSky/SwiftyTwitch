//
//  NumberAnimation.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 02/01/2023.
//

import Foundation
import SwiftUI

struct AnimatableNumberModifier: AnimatableModifier {
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Text("\(Int(number))")
            )
    }
}
extension View {
    func animatingOverlay(for number: Double) -> some View {
        modifier(AnimatableNumberModifier(number: number))
    }
}
