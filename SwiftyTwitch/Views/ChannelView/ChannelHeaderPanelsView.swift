//
//  ChannelHeaderPanelsView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftUI
import AVKit

struct ChannelHeaderPanelsView: View {
    @EnvironmentObject var channelVM: ChannelViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if channelVM.channel.channelInfo.streamData != nil {
            HStack(spacing: 15) {
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.red)
                        .frame(width: 100, height: 25)
                        .reverseMask() {
                            Text("LIVE NOW !")
                                .font(.title2)
                                .bold()
                        }
                    Text("\(channelVM.channel.channelInfo.userData.userDisplayName) is streaming \(channelVM.channel.channelInfo.streamData!.gameName ?? "") !")
                        .font(.title)
                        .bold()
                    Spacer()
                    Text("Watch now among \(channelVM.channel.channelInfo.streamData!.viewerCount.customFormatted) viewers !")
                        .font(.title3)
                }.padding()
                    .padding(.vertical, 20)
                    .frame(width: 300, height: 280, alignment: .topLeading)
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThickMaterial)
                    }
                VStack {
                    PlayerView()
                        .environmentObject(PlayerViewModel(channel: channelVM.channel.channelInfo))
                        .cornerRadius(10)
                }.frame(width: 497, height: 280)
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThickMaterial)
                    }
            }
        } else {
            HStack(spacing: 15) {
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(colorScheme == .dark ? Color.white : Color.secondary)
                        .frame(width: 75, height: 25)
                        .reverseMask() {
                            Text("OFFLINE")
                                .font(.title2)
                                .bold()
                        }
                    Text("\(channelVM.channel.channelInfo.userData.userDisplayName) is offline !")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 10)
                    if !channelVM.lastVideos.isEmpty {
                        Text("Check out their last stream from \(channelVM.lastVideos.first!.publishedDate.timeAgoDisplay())")
                            .font(.title3)
                    } else {
                        Text(channelVM.channel.channelInfo.userData.description ?? "")
                            .font(.title3)
                    }
                }.padding()
                    .padding(.vertical, 20)
                    .frame(width: 300, height: 280, alignment: .topLeading)
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThickMaterial)
                    }
                VStack {
                    AsyncImage(url: channelVM.channel.channelInfo.userData.offlineImageURL, content: { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .frame(width: 500, height: 280)
                    }, placeholder: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThickMaterial)
                    })
                }.frame(width: 500, height: 280)
            }
        }
    }
}
