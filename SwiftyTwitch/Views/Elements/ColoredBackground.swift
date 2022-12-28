//
//  ColoredBackground.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI
import DominantColor

struct ColoredBackground: View {
    let image: NSImage
    var body: some View {
        
        ZStack {
            AngularGradient(gradient: Gradient(colors: {
                var answer: [Color] = []
                let colors = image.dominantColors()
                for color in colors {
                    answer.append(Color(nsColor: color))
                }
                return answer}()), center: .center)
                .saturation(2.5)
                .blur(radius: 70)
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow).opacity(0.7)

        }
    }
}
