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
                .frame(width: 15, height: 15)
                .foregroundColor(.white)
                .font(.system(size: 10, design: .default))
                .opacity(0.8)
                .onTapGesture {
                    if configuration.isOn {
                        player.pause()
                    } else {
                        player.play()
                    }
                    configuration.isOn.toggle()
                }
        }
 
    }
}

struct SoundControlToggleStyle: ToggleStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
 
        return HStack {
            Image(systemName: configuration.isOn ? "speaker.slash.fill" : "speaker.wave.3.fill")
                .resizable()
                .frame(width: configuration.isOn ? 20 : 15, height: 15)
                .foregroundColor(.white)
                .font(.system(size: 10, design: .default))
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
