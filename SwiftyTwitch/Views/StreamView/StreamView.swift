//
//  StreamView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftUI
import WebViewKit

struct StreamView: View {
    @EnvironmentObject var appVM: AppViewModel
    
    @State var timeSinceStarted: String = ""
    let timeRefreshTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    var player: some View {
        PlayerView()
            .background() {
                ZStack {
                    if appVM.streamPlayer!.player != nil {
                        if appVM.streamPlayer!.player?.reasonForWaitingToPlay == .noItemToPlay {
                            AsyncImage(url: appVM.streamPlayer!.channel.userData.offlineImageURL, content: { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                            }, placeholder: {
                                EmptyView()
                            })
                        }
                    }
                }.cornerRadius(10)
            }
            .environmentObject(appVM.streamPlayer!)
            .environmentObject(appVM)
            .aspectRatio(16/9, contentMode: .fit)
            
    }
    var fullScreenPlayer: some View {
        PlayerView()
            .environmentObject(appVM.streamPlayer!)
            .environmentObject(appVM)
            .background() {
                if appVM.ambianceMode {
                    PlayerView()
                        .blur(radius: 100)
                        .environmentObject(appVM.streamPlayer!)
                        .environmentObject(appVM)
                } else {
                    Spacer()
                }
            }
    }
    
    //MARK: - body -> player & pip/fs handling.
    
    var body: some View {
        HStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack {
                        VStack {
                            if appVM.streamPlayer != nil {
                                ZStack {
                                    AsyncImage(url: appVM.streamPlayer!.channel.userData.profileImageURL, content: { image in
                                        ColoredBackground(image: {
                                            HStack {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            }.asNSImage()
                                        }()).isHidden(appVM.ambianceMode)
                                        
                                    }, placeholder: {
                                        Spacer()
                                    })
                                    ZStack {
                                        VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                        Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }.aspectRatio(16/9, contentMode: .fit)
                                        .cornerRadius(10)
                                    if appVM.ambianceMode && !(appVM.streamPlayer != nil ? appVM.streamPlayer!.pictureInPicture : false) {
                                        player
                                            .saturation(2.5)
                                            .blur(radius: 100)
                                    }
                                    player
                                    if appVM.streamPlayer!.pictureInPicture {
                                        ZStack {
                                            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                                .cornerRadius(10)
                                            VStack {
                                                Image(systemName: "rectangle.fill.on.rectangle.fill")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.accentColor)
                                                    .padding()
                                                Text("Picture In Picture mode active.")
                                                    .font(.largeTitle)
                                                Text("Double click anywhere on the player to toggle it off.")
                                                    .font(.callout)
                                            }.opacity(0.8)
                                                
                                        }.onTapGesture(count: 2) {
                                            appVM.streamPlayer!.pictureInPicture = false
                                        }
                                    } else if appVM.streamPlayer!.fullScreen {
                                        ZStack {
                                            VisualEffectView(material: .menu, blendingMode: .withinWindow)
                                                .cornerRadius(10)
                                            VStack {
                                                Image(systemName: "rectangle.inset.filled")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.accentColor)
                                                    .padding()
                                                Text("Full screen mode active.")
                                                    .font(.largeTitle)
                                                Text("Double click anywhere on the player to toggle it off.")
                                                    .font(.callout)
                                            }.opacity(0.8)
                                                
                                        }.onTapGesture(count: 2) {
                                            appVM.streamPlayer!.fullScreen = false
                                        }
                                    }
                                }.animation(.easeInOut(duration: 0.3), value: appVM.streamPlayer!.pictureInPicture)
                            }
                        }.padding(20)
                            .onChange(of: appVM.streamPlayer != nil ? appVM.streamPlayer!.pictureInPicture : false) { newValue in
                                if newValue {
                                    appVM.streamPlayer!.fullScreen = false
                                    player.newPIPWindow(appVM: appVM)
                                } else {
                                    appVM.pictureInPictureWindow?.close()
                                }
                            }
                            .onChange(of: appVM.streamPlayer != nil ? appVM.streamPlayer!.fullScreen : false) { newValue in
                                if newValue {
                                    appVM.streamPlayer!.pictureInPicture = false
                                    fullScreenPlayer.newFullScreenWindow(appVM: appVM)
                                } else {
                                    appVM.fullScreenWindow?.close()
                                }
                            }
                    }
                    
                    //MARK: - stream details.
                    
                    if appVM.streamPlayer != nil {
                        VStack {
                            HStack(alignment: .top) {
                                AsyncImage(url: appVM.streamPlayer!.channel.userData.profileImageURL, content: { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 90, height: 90)
                                        .cornerRadius(6)
                                        .shadow(radius: 5)
                                        .overlay() {
                                            VStack {
                                                Spacer().frame(maxHeight: .infinity)
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(.red)
                                                        .frame(width: 40, height: 20)
                                                        .background() {
                                                            RoundedRectangle(cornerRadius: 5)
                                                                .fill(.red)
                                                                .frame(width: 40, height: 20)
                                                                .blur(radius: 10)
                                                        }
                                                    Text("LIVE")
                                                        .font(.title3)
                                                        .bold()
                                                }.offset(y: 10)
                                            }
                                        }
                                }, placeholder: {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.ultraThickMaterial)
                                        .frame(width: 110, height: 110)
                                })
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(appVM.streamPlayer!.channel.userData.userDisplayName)
                                            .font(.system(size: 25))
                                            .bold()
                                        if appVM.streamPlayer!.channel.userData.broadcasterType == .partner {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(.purple)
                                                .font(.system(size: 15))
                                                .offset(y: -1)
                                        }
                                    }.padding(.bottom, 1)
                                    Text("\(appVM.streamPlayer!.channel.streamData!.title)")
                                        .font(.title3)
                                        .padding(.bottom, 2)
                                    HStack {
                                        Text("\(appVM.streamPlayer!.channel.streamData!.gameName ?? "")")
                                            .font(.headline)
                                    }
                                }.padding(.leading, 10)
                                Spacer()
                                VStack {
                                    HoverView { isHover in
                                        HStack {
                                            Button(action: {
                                            }, label: {
                                                Label("Follow", systemImage: "heart.fill").labelStyle(.iconOnly)
                                            })
                                            Button(action: {
                                                
                                            }, label: {
                                                Label("Notifications", systemImage: "bell.fill").labelStyle(.iconOnly)
                                            })
                                            Button(action: {
                                                
                                            }, label: {
                                                Label("Subscribe", systemImage: "star").labelStyle(.titleAndIcon)
                                            })
                                        }.controlSize(.large)
                                            .disabled(true)
                                            .popover(isPresented: isHover) {
                                                Text("Not supported by twitch API... 😢")
                                                    .padding()
                                            }
                                    }.padding(.bottom, 5)
                                    HStack {
                                        Label("\(appVM.streamPlayer!.channel.streamData!.viewerCount.formatted(.number))", systemImage: "person")
                                            .animation(Animation.easeInOut(duration: 2), value: appVM.streamPlayer!.channel.streamData!.viewerCount)
                                            .padding(.trailing, 5)
                                            .bold()
                                        
                                        Text("\(timeSinceStarted)")
                                            .onReceive(timeRefreshTimer) { _ in
                                                timeSinceStarted = appVM.streamPlayer!.channel.streamData!.startTime.timeAgoDetailDisplay
                                            }
                                            .frame(width: 50)
                                            .padding(.trailing, 5)
                                        
                                        ShareLink(item: URL(string: "https://twitch.tv/\(appVM.streamPlayer!.channel.userData.userLoginName)")!)
                                            .buttonStyle(.plain)
                                            .labelStyle(.iconOnly)
                                            .offset(y: -0.5)
                                        Menu(content: {
                                            Button(action: {
                                                "https://twitch.tv/\(appVM.streamPlayer!.channel.userData.userLoginName)".copy()
                                            }, label: {
                                                Label("Copy link to clipboard", systemImage: "doc.on.doc")
                                            })
                                            Divider()
                                            Button(action: {
                                                NSWorkspace.shared.open(URL(string: "https://twitch.tv/\(appVM.streamPlayer!.channel.userData.userLoginName)")!)
                                            }, label: {
                                                Label("Open stream in web browser", systemImage: "globe")
                                            })
                                        }, label: {
                                            Label("More", systemImage: "ellipsis").labelStyle(.iconOnly)
                                        }).menuStyle(BorderlessButtonMenuStyle())
                                            .menuIndicator(.hidden)
                                            .frame(width: 20)
                                    }
                                }
                            }.padding(.leading, 20)
                                .padding(.trailing, 20)
                            Spacer().frame(height: 200)
                        }.textSelection(.enabled)
                            .navigationTitle(appVM.streamPlayer!.channel.userData.userDisplayName)
                    }
                }.padding(.trailing, 200)
                
            }.padding(.trailing, -200)
            VStack {
                if appVM.theaterMode {
                    ZStack {
                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                        WebView(url: URL(string: "https://www.twitch.tv/popout/\(appVM.streamPlayer!.channel.userData.userLoginName)/chat"))
                    }.cornerRadius(10)
                        .shadow(radius: 3)
                        .frame(width: 350)
                        .padding(.vertical, 20)
                        .padding(.trailing, 20)
                }
            }
        }
    }
}
