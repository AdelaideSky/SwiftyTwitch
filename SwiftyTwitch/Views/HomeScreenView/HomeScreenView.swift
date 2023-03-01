//
//  HomeScreenView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 03/01/2023.
//

import Foundation
import SwiftUI
import AVKit

struct HomeScreenView: View {
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var appVM: AppViewModel
//    @State var player: AVPlayer? = nil
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                AsyncImage(url: appVM.userInfos?.profileImageURL, content: { image in
                    ColoredBackground(image: {
                        HStack {
                            image
                                .resizable()
                                .scaledToFill()
                        }.asNSImage()
                    }()).clipped()
                        .frame(height: 400)
                    
                }, placeholder: {
                    Spacer()
                        .frame(height: 400)
                        .frame(maxWidth: .infinity)
                })
                if let recommandedStream = navigationVM.followList.follows.first(where: {$0.streamData != nil}) {
                    HomeHeaderPanelsView(channel: recommandedStream)
                        .padding(.vertical, 10)
                }
            }
            StreamsRowElement("Your live channels", channels: navigationVM.followList.follows.filter({$0.streamData != nil}))
            Spacer()
        }
        
//        Text("Welcome back, \(appVM.userInfos?.userDisplayName ?? ",,") !").font(.largeTitle)
//        AsyncImage(url: appVM.userInfos?.profileImageURL)
//        VStack {
//            if player != nil {
//                VideoPlayer(player: player)
//            }
//        }.onAppear {
//            player = AVPlayer(url: URL(string: "https://d2nvs31859zcd8.cloudfront.net/636d6d4a7dbcc44d1025_thesushidragon_41670070379_1672540787/720p30/index-muted-NEZCET67JT.m3u8")!)
//        }
    }
}

