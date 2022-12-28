//
//  ChannelView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftUI

struct ChannelView: View {
    @EnvironmentObject var channelVM: ChannelViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                AsyncImage(url: channelVM.channel.channelInfo.userData.profileImageURL, content: { image in
                    ColoredBackground(image: {
                        HStack {
                            image
                                .resizable()
                                .scaledToFill()
                        }.asNSImage()
                    }()).clipped()
                        .frame(height: 338)
                    
                }, placeholder: {
                    Spacer()
                        .frame(height: 338)
                        .frame(maxWidth: .infinity)
                })
                
                ChannelInfoBarView()
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


struct ChannelInfoBarView: View {
    @EnvironmentObject var channelVM: ChannelViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: channelVM.channel.channelInfo.userData.profileImageURL, content: { image in
                image
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .cornerRadius(6)
                    .offset(y: -50)
                    .shadow(radius: 5)
                
            }, placeholder: {
                ProgressView()
                    .scaleEffect(0.4)
                    .opacity(0.7)
                    .padding()
                    .frame(width: 110, height: 110)
                    .offset(y: -50)
            })
            VStack(alignment: .leading) {
                HStack {
                    Text(channelVM.channel.channelInfo.userData.userDisplayName)
                        .font(.system(size: 28))
                        .bold()
                    if channelVM.channel.channelInfo.userData.broadcasterType == .partner {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 15))
                            .offset(y: 2)
                    }
                }.padding(.bottom, 1)
                Text("\(channelVM.channel.followerCount.customFormatted) followers")
                    .font(.system(size: 13))
                    .opacity(0.8)
            }.padding(.leading, 10)
            Spacer()
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
                Button(action: {
                    
                }, label: {
                    Label("More", systemImage: "ellipsis").labelStyle(.iconOnly)
                }).buttonStyle(.plain)
            }.controlSize(.large)
        }.padding(.leading, 40)
            .padding(.trailing, 20)
    }
}
