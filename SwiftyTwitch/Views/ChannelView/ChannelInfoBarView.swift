//
//  ChannelInfoBar.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftUI
import WebViewKit

struct ChannelInfoBarView: View {
    @EnvironmentObject var channelVM: ChannelViewModel
    
    @State var showSubPopover: Bool = false
    @State var showReportPopover: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: channelVM.channel.channelInfo.userData.profileImageURL, content: { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .cornerRadius(6)
                    .offset(y: -50)
                    .shadow(radius: 5)
            }, placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.ultraThickMaterial)
                    .frame(width: 110, height: 110)
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
                            .offset(y: -2)
                    }
                }.padding(.bottom, 1)
                
            }.padding(.leading, 10)
            Spacer()
            HStack {
                HoverView { isHover in
                    HStack {
                        Button(action: {
                        }, label: {
                            if channelVM.channel.channelInfo.userData.broadcasterType != .normal {
                                Label("Follow", systemImage: "heart.fill").labelStyle(.iconOnly)
                            } else {
                                Label("Follow", systemImage: "heart.fill").labelStyle(.titleAndIcon)
                            }
                        })
                        Button(action: {
                            
                        }, label: {
                            Label("Notifications", systemImage: "bell.fill").labelStyle(.iconOnly)
                        })
                    }.controlSize(.large)
                        .disabled(true)
                        .popover(isPresented: isHover) {
                            Text("Not supported by twitch API... 😢")
                                .padding()
                        }
                }
                if channelVM.channel.channelInfo.userData.broadcasterType != .normal {
                    Button(action: {
                        showSubPopover.toggle()
                    }, label: {
                        Label("Subscribe", systemImage: "star").labelStyle(.titleAndIcon)
                    }).sheet(isPresented: $showSubPopover) {
                        VStack {
                            WebView(url: URL(string: "https://www.twitch.tv/subs/\(channelVM.channel.channelInfo.userData.userLoginName)"))
                        }.frame(width: 400, height: 700)
                    }
                }
                Menu(content: {
                    Button(action: {
                        showReportPopover.toggle()
                    }, label: {
                        Label("Report...", systemImage: "exclamationmark.bubble")
                    })
                }, label: {
                    Label("More", systemImage: "ellipsis").labelStyle(.iconOnly)
                }).menuStyle(BorderlessButtonMenuStyle())
                    .menuIndicator(.hidden)
                    .frame(width: 20)
                    .sheet(isPresented: $showReportPopover) {
                        VStack {
                            WebView(url: URL(string: "https://m.twitch.tv/\(channelVM.channel.channelInfo.userData.userLoginName)/report"))
                        }.frame(width: 400, height: 550)
                            .interactiveDismissDisabled(false)
                    }
            }.controlSize(.large)
            
        }.padding(.leading, 40)
            .padding(.trailing, 20)
    }
}
