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
import SDWebImageSwiftUI

struct PlayerView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    @EnvironmentObject var appVM: AppViewModel
    
    var body: some View {
        VStack {
            if playerVM.status != .error {
                if playerVM.player != nil {
                    CustomPlayerView(player: playerVM.player!)
                        .overlay() {
                            if playerVM.player != nil {
                                PlayerOverlayView()
                            }
                        }
                        .background(Color.clear)
                } else {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            } else if playerVM.status == .error{
                ZStack {
                    Spacer().frame(maxWidth: .infinity, maxHeight: .infinity).aspectRatio(16/9, contentMode: .fit)
                    VStack {
                        Image(systemName: "exclamationmark.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                            .opacity(0.5)
                            .frame(width: 70)
                        VStack {
                            Text("ERROR")
                                .font(.headline)
                                .opacity(0.5)
                                .padding(.bottom, 3)
                            Text("Something went wrong loading this stream... Double click anywhere to reload the player")
                                .font(.footnote)
                                .opacity(0.5)
                        }.padding(.vertical, 20)
                    }
                }.contentShape(RoundedRectangle(cornerRadius: 5))
                .onTapGesture(count: 2) {
                    playerVM.loadPlayer()
                }
            }
            
        }.cornerRadius(10)
    }
}

struct PlayerOverlayView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    @EnvironmentObject var appVM: AppViewModel
    
    @State var isHover = false
    @State var showOverlay = false
    @State var showDetailsVolume = false
    
    @State var mouseTimer: Timer? = nil
    
    var body: some View {
        if playerVM.player != nil {
            if playerVM.player!.reasonForWaitingToPlay == .toMinimizeStalls {
                ProgressView()
            }
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        if playerVM.pictureInPicture {
                            ZStack {
                                VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                Image(systemName: "xmark")
                                    .font(.system(size: 17, design: .default))
                            }.mask() {
                                Circle().frame(width: 30, height: 30)
                            }
                            .onTapGesture {
                                playerVM.pictureInPicture = false
                            }
                            .frame(width: 30, height: 30)
                            
                        } else if playerVM.fullScreen {
                            VStack(alignment: .leading) {
                                HStack {
                                    WebImage(url: playerVM.channel.userData.profileImageURL)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(6)
                                        .shadow(radius: 5)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 10)
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(playerVM.channel.userData.userDisplayName)
                                                .font(.system(size: 25))
                                                .bold()
                                            if playerVM.channel.userData.broadcasterType == .partner {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .foregroundColor(.purple)
                                                    .font(.system(size: 15))
                                            }
                                        }.padding(.bottom, 0.5)
                                        Text("\(playerVM.channel.streamData!.title)")
                                            .font(.title3)
                                            .padding(.bottom, 2)
                                        HStack {
                                            Text("\(playerVM.channel.streamData!.gameName!.isEmpty ? ("Plays "+(playerVM.channel.streamData!.gameName ?? "")) : "Streams") for \(playerVM.channel.streamData!.viewerCount) viewers")
                                                .font(.headline)
                                        }
                                    }.padding(10)
                                    
                                }.background() {
                                    VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                        .cornerRadius(10)
                                        .opacity(0.5)
                                }
                                .shadow(radius: 3)
                                if appVM.chatPanelConfig == .left {
                                    VStack(spacing: 0) {
//                                        HStack {
//                                            Spacer()
//                                            Button(action: {
//                                                appVM.chatPanelConfig = .right
//                                            }) {
//                                                Label("Move to right", systemImage: "arrowshape.turn.up.right.fill").labelStyle(.iconOnly)
//                                            }
//                                        }.controlSize(.small)
//                                            .buttonStyle(.plain)
//                                            .shadow(radius: 2)
//                                            .padding(.bottom, 3)
//                                            .opacity(0.8)
                                        ZStack {
                                            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                                            CustomWebView(data: WebViewData(url: URL(string: "https://www.twitch.tv/popout/\(appVM.streamPlayer!.channel.userData.userLoginName)/chat")))
                                        }.cornerRadius(10)
                                            .shadow(radius: 3)
                                    }.frame(width: 350)
                                        .padding(.top, 10)
                                        .padding(.bottom, 15)
                                        
                                }
                            }
                        }
                        Spacer(minLength: 20)
                        VStack(alignment: .trailing) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.red)
                                    .frame(width: 50, height: 25)
                                Text("LIVE")
                                    .font(.title2)
                                    .bold()
                            }
                            if playerVM.fullScreen && appVM.chatPanelConfig == .right {
                                VStack(spacing: 0) {
//                                    HStack {
//                                        Button(action: {
//                                            appVM.chatPanelConfig = .left
//                                        }) {
//                                            Label("Move to left", systemImage: "arrowshape.turn.up.left.fill").labelStyle(.iconOnly)
//                                        }
//                                        Spacer()
//                                    }.controlSize(.small)
//                                        .buttonStyle(.plain)
//                                        .shadow(radius: 2)
//                                        .padding(.bottom, 3)
//                                        .opacity(0.8)
                                    ZStack {
                                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                                        CustomWebView(data: WebViewData(url: URL(string: "https://www.twitch.tv/popout/\(appVM.streamPlayer!.channel.userData.userLoginName)/chat")))
                                    }.cornerRadius(10)
                                        .shadow(radius: 3)
                                }.frame(width: 350)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                            }
                        }
                        
                    }.padding(10)
                    Spacer()
                    HStack() {
                        Toggle("Play/Pause", isOn: $playerVM.isPlaying)
                            .toggleStyle(MediaControlToggleStyle(player: playerVM.player!))
                            .padding(.leading, 15)
                            .padding(.trailing, 5)
                            .keyboardShortcut(.space, modifiers: [])
                            .onChange(of: playerVM.isPlaying) { newValue in
                                if newValue {
                                    guard let livePosition = playerVM.player!.currentItem?.seekableTimeRanges.last as? CMTimeRange else {
                                        return
                                    }
                                    playerVM.player!.seek(to: CMTimeRangeGetEnd(livePosition))
                                    playerVM.player!.play()
                                } else {
                                    playerVM.player!.pause()
                                }
                            }
                        HStack {
                            ZStack {
                                Toggle("Mute", isOn: $playerVM.player.unwrap()!.isMuted)
                                    .hidden()
                                    .frame(width: 1)
                                    .keyboardShortcut("m")
                                Label("Volume", systemImage: playerVM.player!.isMuted ? "speaker.slash.fill" : playerVM.player!.volume == 0 ? "speaker.slash.fill" : "speaker.wave.3.fill").labelStyle(.iconOnly)
                                    .font(.system(size: 15, design: .default))
                                    .opacity(showDetailsVolume ? 1 : 0.9)
                                    .offset(y: -0.5)
                                    .onTapGesture {
                                        playerVM.player!.isMuted.toggle()
                                    }
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
                        Text(playerVM.selectedStream?.formatted ?? "Loading...")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.clear)
                            .padding(.horizontal, 5)
                            .frame(height: 18)
                            .overlay() {
                                RoundedRectangle(cornerRadius: 7)
                                    .background(Color.primary)
                                    .reverseMask() {
                                        Text(playerVM.selectedStream?.formatted ?? "Loading...")
                                            .font(.caption)
                                            .bold()
                                            .padding(.horizontal, 5)
                                    }
                            }
                            .mask() {
                                RoundedRectangle(cornerRadius: 7)
                            }
                            .opacity(0.5)
                            .padding(.horizontal, 5)
                        
                        Menu {
                            Picker("Quality", selection: $playerVM.selectedStream) {
                                ForEach(Array(playerVM.streams.keys.sorted(by: { Int($0.rawValue.filter("0123456789".contains)) ?? 0 > Int($1.rawValue.filter("0123456789".contains)) ?? 0 })), id: \.self) { stream in
                                    Text(stream.formatted).tag(stream as StreamQuality?)
                                }
                            }
                            Divider()
                            Toggle("Ambiance mode", isOn: $appVM.ambianceMode)
                            if playerVM.fullScreen {
                                Picker("Chat panel", selection: $appVM.chatPanelConfig) {
                                    Text("On right").tag(ChatPanelConfig.right)
                                    Text("On left").tag(ChatPanelConfig.left)
                                    Text("Desactivated").tag(ChatPanelConfig.none)
                                }
                            }
                            Divider()
                            Button("Reload player") {
                                playerVM.player = nil
                                playerVM.loadPlayer()
                            }
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                                .bold()
                                .scaleEffect(20)
                        }.menuStyle(BorderlessButtonMenuStyle())
                            .menuIndicator(.hidden)
                            .frame(width: 20)
                            .opacity(0.9)
                            .scaleEffect(1.2)
                            .offset(y: -1)
                            .onChange(of: playerVM.selectedStream) { newValue in
                                playerVM.changeQuality()
                            }
                            .padding(.trailing, -1.5)
                        
                        Toggle("Theater mode", isOn: $appVM.theaterMode)
                            .keyboardShortcut("t")
                            .toggleStyle(TheaterModeToggleStyle())
                            .padding(.horizontal, 5)
                            .opacity(0.9)
                        Toggle("Picture In Picture mode", isOn: $playerVM.pictureInPicture)
                            .keyboardShortcut("p")
                            .toggleStyle(PictureInPictureToggleStyle())
                            .padding(.horizontal, 5)
                            .opacity(0.9)
                            
                        Toggle("FullScreen", isOn: $playerVM.fullScreen)
                            .keyboardShortcut("f")
                            .toggleStyle(FullScreenToggleStyle())
                            .padding(.leading, 5)
                            .padding(.trailing, 15)
                            .opacity(0.9)
                            
                    }.frame(height: 35, alignment: .leading)
                        .background(Material.thin)
                        .cornerRadius(10)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                }.opacity(showOverlay ? 1 : 0)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.2), value: showOverlay)
                .onHover() { hoverState in
                    if !hoverState {
                        showOverlay = false
                    }
                    isHover = hoverState
                }
                .onMouseMove() { _ in
                    showOverlay = true
                    if mouseTimer != nil {
                        mouseTimer!.invalidate()
                    }
                    mouseTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(3), repeats: false, block: { _ in
                        showOverlay = false
                        if isHover {
                            NSCursor.setHiddenUntilMouseMoves(true)
                        }
                    })
                }
        }
        
    }
}
