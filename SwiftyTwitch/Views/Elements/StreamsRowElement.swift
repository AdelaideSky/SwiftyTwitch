//
//  StreamsRowElement.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI
import SwiftTwitch
import SDWebImageSwiftUI

struct StreamsRowElement: View {
    var title: String
    var channels: [Follow]
    
    init(_ title: String, channels: [Follow]) {
        self.title = title
        self.channels = channels
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(channels, id: \.userData.userId) { channel in
                        if channel.streamData != nil {
                            StreamElement(channel: channel).padding(.horizontal, 5)
                                .padding(.vertical, 2)
                        }
                    }
                }
            }
            
        }.padding(.horizontal)
    }
}

struct StreamElement: View {
    var channel: Follow
    
    var body: some View {
        HoverView(delay: false) { isHover in
            VStack {
                VStack(alignment: .leading) {
                    ZStack {
                        
                        AsyncImage(url: URL(string: channel.streamData!.thumbnailURLString.replacing("{width}", with: "320").replacing("{height}", with: "180")), content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(5)
                        }, placeholder: {
                            ProgressView().scaleEffect(0.5)
                                .frame(width: 320, height: 180)
                        })
                        VStack(alignment: .leading) {
                            
                            Spacer().frame(maxWidth: .infinity)
                            HStack {
                                Text("\(channel.streamData!.viewerCount.customFormatted) viewers")
                                    .padding(3)
                                    .background() {
                                        VisualEffectView(material: .popover, blendingMode: .withinWindow)
                                            .cornerRadius(5)
                                    }
                                Spacer().frame(maxWidth: .infinity)
                                Text(channel.streamData!.startTime.timeAgoDetailDisplay)
                                    .padding(3)
                                    .background() {
                                        VisualEffectView(material: .popover, blendingMode: .withinWindow)
                                            .cornerRadius(5)
                                    }
                            }
                        }.padding(10)
                            .shadow(radius: 3)
                    }.frame(width: 320, height: 180)
                    .scaleEffect(isHover.wrappedValue ? 1.03 : 1)
                    .shadow(radius: isHover.wrappedValue ? 3 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isHover.wrappedValue)
                    HStack {
                        WebImage(url: channel.userData.profileImageURL)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(7)
                            .frame(width: 32)
                            .padding(.horizontal, 5)
                        VStack(alignment: .leading) {
                            Text(channel.streamData!.title)
                                .font(.headline)
                                .lineLimit(2)
                            Text(channel.userData.userDisplayName)
                                .opacity(0.7)
                        }
                    }
                }.frame(width: 320)
                    .padding(10)
            }
            .contextMenu() {
                Button(action: {
                    "https://twitch.tv/\(channel.userData.userLoginName)".copy()
                }, label: {
                    Label("Copy link to clipboard", systemImage: "doc.on.doc")
                })
                ShareLink(item: URL(string:"https://twitch.tv/\(channel.userData.userLoginName)")!)
                Divider()
                Button(action: {
                    NSWorkspace.shared.open(URL(string:"https://twitch.tv/\(channel.userData.userLoginName)")!)
                }, label: {
                    Label("Open link", systemImage: "globe")
                })
            }
            .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.separator, lineWidth: 1)
                    
                )
            .background() {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.separator)
                    .opacity(0.2)
            }
        }
    }
}
