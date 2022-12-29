//
//  ChannelListElement.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ChannelListElement: View {
    var channels: [Follow]
    
    
    var body: some View {
        ForEach(channels.filter({$0.streamData != nil}), id: \.userData) { channel in
            ChannelListRowElement(channel: channel)
        }
        ForEach(channels.filter({$0.streamData == nil}), id: \.userData) { channel in
            ChannelListRowElement(channel: channel)
        }
    }
}

struct ChannelListRowElement: View {
    var channel: Follow
    var channelVM: ChannelViewModel
    
    init(channel: Follow) {
        self.channel = channel
        self.channelVM = ChannelViewModel(channel: channel)
    }

    var body: some View {
        if channel.streamData != nil {
            NavigationLink(destination: ChannelView().environmentObject(channelVM), label: {
                HoverView { isHover in
                    HStack(alignment: .center) {
                        WebImage(url: channel.userData.profileImageURL)
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .cornerRadius(6)
                        if channel.streamData!.gameName != nil && channel.streamData!.gameName != "" {
                            VStack(alignment: .leading) {
                                HStack() {
                                    Text(channel.streamData!.streamerUserName)
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    HStack(spacing: 4) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 7))
                                            .foregroundColor(.red)
                                        Text("\(channel.streamData!.viewerCount.customFormatted)")
                                            .font(.subheadline)
                                    }.frame(minWidth: 40)
                                }
                                
                                Text(channel.streamData!.gameName ?? "nil")
                                    .font(.subheadline)
                                    .opacity(0.5)
                            }
                            
                        } else {
                            HStack() {
                                Text(channel.streamData!.streamerUserName)
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack(spacing: 4) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 7))
                                        .foregroundColor(.red)
                                    Text("\(channel.streamData!.viewerCount.customFormatted)")
                                        .font(.subheadline)
                                }.frame(minWidth: 40)
                            }
                        }
                        
                        
                    }.frame(height: 30)
                        .padding(.vertical, 2.5)
                        .popover(isPresented: isHover, arrowEdge: Edge.trailing) {
                            VStack {
                                Text(channel.streamData!.title)
                                    .font(.system(size: 10))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }.padding(10)
                                .frame(minWidth: 50, maxWidth: 200, maxHeight: 50)
                                .interactiveDismissDisabled()
                            
                        }
                }
                
            }).contextMenu() {
                Button(action: {
                    "https://twitch.tv/\(channel.userData.userLoginName)".copy()
                }, label: {
                    Label("Copy link to clipboard", systemImage: "doc.on.doc")
                })
                ShareLink(item: URL(string: "https://twitch.tv/\(channel.userData.userLoginName)")!)
                Divider()
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "https://twitch.tv/\(channel.userData.userLoginName)")!)
                }, label: {
                    Label("Open link", systemImage: "globe")
                })
            }
        } else {
            NavigationLink(destination: ChannelView().environmentObject(channelVM), label: {
                HStack(alignment: .center) {
                    WebImage(url: channel.userData.profileImageURL)
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .cornerRadius(6)
                        .saturation(0)

                    Text(channel.userData.userDisplayName)
                        .font(.system(size: 15))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Offline")
                        .font(.subheadline)
                        .opacity(0.8)

                }.frame(height: 30)
                    .padding(.vertical, 2.5)
            }).contextMenu() {
                Button(action: {
                    "https://twitch.tv/\(channel.userData.userLoginName)".copy()
                }, label: {
                    Label("Copy link to clipboard", systemImage: "doc.on.doc")
                })
                ShareLink(item: URL(string: "https://twitch.tv/\(channel.userData.userLoginName)")!)
                Divider()
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "https://twitch.tv/\(channel.userData.userLoginName)")!)
                }, label: {
                    Label("Open link", systemImage: "globe")
                })
            }
        }
    }
}
