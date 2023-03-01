//
//  NavigationView.swift
//  SwiftyYouTube
//
//  Created by Adélaïde Sky on 24/12/2022.
//

import Foundation
import SwiftUI

struct NavigationView: View {
    @EnvironmentObject var appVM: AppViewModel
    @EnvironmentObject var navigationVM: NavigationViewModel
    
    let autoRefreshTimer = Timer.publish(every: 120, on: .main, in: .common).autoconnect()
    var body: some View {
        NavigationSplitView(sidebar: {
            List() {
                NavigationLink(destination: HomeScreenView()) {
                    Label("Home", systemImage: "house")
                }
                Spacer().frame(height: 10)
                Group {
                    Text("For you")
                        .font(.title2)
                        .fontWeight(.bold)
                    Group {
                        HStack(alignment: .top) {
                            Text("FOLLOWED CHANNELS")
                                .font(.system(size: 10))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: {
                                navigationVM.followList.follows = []
                                navigationVM.loadFollowList(userID: appVM.userID)
                            }, label: {
                                Label("Refresh", systemImage: "arrow.clockwise").labelStyle(.iconOnly)
                                    .opacity(0.8)
                                    .font(.system(size: 10))
                            }).buttonStyle(PlainButtonStyle())
                        }
                        switch navigationVM.status {
                            case .none:
                                Spacer()
                            case .startedFetching:
                            HStack {
                                Spacer()
                                ProgressView().scaleEffect(0.5)
                                Spacer()
                            }
                            case .error:
                                Text("ERROR")
                                    .font(.footnote)
                                    .opacity(0.5)
                        case .doneFetching:
                            ChannelListElement(channels: navigationVM.followList.follows)
                            switch navigationVM.loadMoreFollowsStatus {
                            case .none:
                                if navigationVM.followList.total > navigationVM.followList.follows.count {
                                    Button(action: {
                                        navigationVM.loadMoreFollows(userID: appVM.userID)
                                    }, label: {
                                        Label("Show more", systemImage: "chevron.down")
                                    }).buttonStyle(PlainButtonStyle())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            case .startedFetching:
                                HStack {
                                    Spacer()
                                    ProgressView().scaleEffect(0.5)
                                    Spacer()
                                }
                            case .error:
                                Text("ERROR")
                                    .font(.footnote)
                                    .opacity(0.5)
                            case .doneFetching:
                                HStack {
                                    if navigationVM.followList.total > navigationVM.followList.follows.count {
                                        Button(action: {
                                            navigationVM.loadMoreFollows(userID: appVM.userID)
                                        }, label: {
                                            Label("Show more", systemImage: "chevron.down")
                                        }).buttonStyle(PlainButtonStyle())
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Button(action: {
                                        navigationVM.showLessFollows()
                                    }, label: {
                                        Label("Show less", systemImage: "chevron.up").labelStyle(.iconOnly)
                                    }).buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                        }
                    }
                    Spacer()
                    Group {
                        HStack(alignment: .top) {
                            Text("TOP STREAMS")
                                .font(.system(size: 10))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: {
                                navigationVM.topStreams = []
                                navigationVM.loadTopStreams()
                            }, label: {
                                Label("Refresh", systemImage: "arrow.clockwise").labelStyle(.iconOnly)
                                    .opacity(0.8)
                                    .font(.system(size: 10))
                            }).buttonStyle(PlainButtonStyle())
                        }
                        switch navigationVM.loadTopStreamsStatus {
                        case .none:
                            Spacer()
                        case .startedFetching:
                            HStack {
                                Spacer()
                                ProgressView().scaleEffect(0.5)
                                Spacer()
                            }
                        case .error:
                            Text("ERROR")
                                .font(.footnote)
                                .opacity(0.5)
                        case .doneFetching:
                            ChannelListElement(channels: navigationVM.topStreams)
                        }
                    }
                }                                
            }
            .font(.caption)
            .listStyle(SidebarListStyle())
            .navigationTitle("SwiftyYouTube")
            .frame(minWidth: 250, idealWidth: 250)
            
        }, detail: {
            switch navigationVM.status {
            case .none:
                Text("Waiting for fetching streams...")
            case .startedFetching:
                LoadingElement()
            case .doneFetching:
                HomeScreenView()
            case .error:
                Text("ERROR")
                    .font(.footnote)
                    .opacity(0.5)
            }
        }).onAppear() {
            navigationVM.loadFollowList(userID: appVM.userID)
            navigationVM.loadTopStreams()
        }
        .onReceive(autoRefreshTimer) { _ in
            navigationVM.quietFollowRefresh(userID: appVM.userID)
            navigationVM.quietTopStreamsRefresh()
        }
    }
}
