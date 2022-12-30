//
//  ToggleStyle.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftUI
import AVFoundation

struct MediaControlToggleStyle: ToggleStyle {
    var player: AVPlayer
 
    func makeBody(configuration: Self.Configuration) -> some View {
 
        return HStack {
            Image(systemName: configuration.isOn ? "pause.fill" : "play.fill")
                .resizable()
                .frame(width: 14, height: 14)
                .font(.system(size: 10, design: .default))
                .opacity(0.8)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
 
    }
}

struct TheaterModeToggleStyle: ToggleStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            Image(systemName: "sidebar.trailing")
                .resizable()
                .frame(width: 20, height: 15)
                .font(.system(size: 10, design: .default))
                .foregroundColor(configuration.isOn ? .accentColor : .primary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
 
    }
}
struct PictureInPictureToggleStyle: ToggleStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "rectangle.fill.on.rectangle.fill" : "rectangle.on.rectangle")
                .resizable()
                .frame(width: 18, height: 15)
                .font(.system(size: 10, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
 
    }
}

struct FullScreenToggleStyle: ToggleStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                .resizable()
                .frame(width: 15, height: 15)
                .font(.system(size: 10, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
 
    }
}

extension Binding {
    func unwrap<Wrapped>() -> Binding<Wrapped>? where Optional<Wrapped> == Value {
        guard let value = self.wrappedValue else { return nil }
        return Binding<Wrapped>(
            get: {
                return value
            },
            set: { value in
                self.wrappedValue = value
            }
        )
    }
}
