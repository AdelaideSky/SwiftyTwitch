//
//  HomeHeaderPanelsView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftUI
import AVKit

struct HomeHeaderPanelsView: View {
    @EnvironmentObject var navigationVM: NavigationViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var PVM: PlayerViewModel?
    var channel: Follow
    var body: some View {
        if channel.streamData != nil {
            HStack(spacing: 15) {
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.accentColor)
                        .frame(width: 100, height: 25)
                        .reverseMask() {
                            Text("FOR YOU")
                                .font(.title2)
                                .bold()
                        }
                        .padding(.bottom, 5)
                    Text("\(channel.userData.userDisplayName) is streaming \(channel.streamData!.gameName ?? "") !")
                        .font(.title)
                        .bold()
                    Spacer()
                    Text("Watch now among \(channel.streamData!.viewerCount.customFormatted) viewers !")
                        .font(.title3)
                }.padding()
                    .padding(.vertical, 5)
                    .frame(width: 300, height: 280, alignment: .topLeading)
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThickMaterial)
                    }
                VStack {
                    if PVM != nil {
                        PlayerView()
                            .environmentObject(PVM!)
                            .cornerRadius(10)
                    }
                }.frame(width: 497, height: 280)
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThickMaterial)
                    }
                    .onAppear() {
                        PVM = PlayerViewModel(channel: channel, autoPlay: false)
                    }
                    .onDisappear() {
                        PVM?.refreshTimer?.invalidate()
                        PVM = nil
                    }
            }
        }
    }
}
