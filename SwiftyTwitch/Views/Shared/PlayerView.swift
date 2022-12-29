//
//  PlayerView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import AVKit
import AVFoundation
import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    
    var body: some View {
        VStack {
            if playerVM.player != nil {
                CustomPlayerView(player: playerVM.player!)
                    .overlay() {
                        PlayerOverlayView()
                    }
                    .background() {
                        ZStack {
                            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                            ProgressView()
                                .scaleEffect(0.5)
                        }.cornerRadius(10)
                    }
                    .onDisappear() {
                        if playerVM.player != nil {
                            playerVM.player!.pause()
                        }
                    }
            }
        }.cornerRadius(10)
    }
}

struct PlayerOverlayView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    
    @State var isHover = false
    @State var showDetailsVolume = false
    
    var body: some View {
        if playerVM.player!.reasonForWaitingToPlay == .toMinimizeStalls {
            ProgressView()
        }
        
        VStack(alignment: .leading) {
            if isHover {
                Spacer().frame(maxHeight: .infinity)
                HStack() {
                    Toggle("", isOn: $playerVM.isPlaying)
                        .toggleStyle(MediaControlToggleStyle(player: playerVM.player!))
                        .padding(.leading, 15)
                        .padding(.trailing, 5)
                    HStack {
                        Label("Volume", systemImage: playerVM.player!.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill").labelStyle(.iconOnly)
                            .font(.system(size: 15, design: .default))
                            .opacity(showDetailsVolume ? 1 : 0.9)
                            .offset(y: -0.5)
                            .onTapGesture {
                                playerVM.player!.isMuted.toggle()
                            }
                        if showDetailsVolume {
                            Slider(value: $playerVM.player.unwrap()!.volume)
                                .frame(width: 100)
                        }
                    }.onHover() { hoverState in
                        showDetailsVolume = hoverState
                    }
                    .animation(.default, value: showDetailsVolume)
                    .controlSize(.small)
                    Spacer().frame(maxWidth: .infinity)
                    Menu {
                        Picker("Quality", selection: $playerVM.selectedStream) {
                            ForEach(Array(playerVM.streams.keys), id: \.self) { stream in
                                Text(stream.rawValue).tag(stream as StreamQuality?)
                            }
                        }
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 20, design: .default))
                            .bold()
                            .opacity(0.9)
                    }.menuStyle(BorderlessButtonMenuStyle())
                        .menuIndicator(.hidden)
                        .padding(.trailing, 15)
                        .frame(width: 30)
                        .onChange(of: playerVM.selectedStream) { newValue in
                            print("onChange")
                            playerVM.changeQuality()
                        }
                    
                }.frame(height: 35, alignment: .leading)
                    .background(Material.thin)
                    .cornerRadius(10)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 10)
                
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .animation(.easeInOut(duration: 0.2), value: isHover)
            .onHover() { hoverState in
                isHover = hoverState
            }
    }
}
