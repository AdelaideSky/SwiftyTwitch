//
//  ChannelView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
struct ChannelView: View {
    @EnvironmentObject var channelVM: ChannelViewModel
    @EnvironmentObject var appVM: AppViewModel

    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack(alignment: .leading) {
                    ZStack {
                        AsyncImage(url: channelVM.channel.channelInfo.userData.profileImageURL, content: { image in
                            ColoredBackground(image: {
                                HStack {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                }.asNSImage()
                            }()).clipped()
                                .frame(height: 450)
                            
                        }, placeholder: {
                            Spacer()
                                .frame(height: 450)
                                .frame(maxWidth: .infinity)
                        })
                        ChannelHeaderPanelsView()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ChannelInfoBarView()
                        if channelVM.channel.channelInfo.userData.description != nil && !(channelVM.channel.channelInfo.userData.description ?? "").isEmpty {
                            Text(channelVM.channel.channelInfo.userData.description ?? "")
                                .font(.title3)
                                .padding()
                                .frame(minWidth: 100, maxWidth: 600, minHeight: 40, maxHeight: 120)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(.separator, lineWidth: 1)
                                        
                                    )
                                .background() {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.separator)
                                        .opacity(0.2)
                                }
                                .fixedSize(horizontal: false, vertical: true)

                                .padding(.leading, 40)
                                .padding(.bottom, 20)
                                .padding(.top, -20)
                        }
                    }
                    if !channelVM.lastVideos.isEmpty {
                        VideosRowElement("Recent broadcasts", videos: channelVM.lastVideos).padding(.bottom, 10)
                    }
                    if !channelVM.lastClips.isEmpty {
                        ClipsRowElement(title: "Popular Clips", clips: channelVM.lastClips)
                    }
                    if channelVM.lastClips.isEmpty && channelVM.lastVideos.isEmpty {
                        VStack {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.accentColor)
                                .padding()
                            Text("Hmmm... It's pretty empty here...")
                                .font(.largeTitle)
                            Text("Here, take this cup of coffee !")
                                .font(.callout)
                        }.opacity(0.8)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            .padding(.bottom, 30)

                    }
                    Spacer().frame(maxHeight: .infinity)
                }
                    
                if channelVM.status == .startedFetching {
                    Rectangle().fill(.background)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    LoadingElement()
                }

            }
        }
    }
}

