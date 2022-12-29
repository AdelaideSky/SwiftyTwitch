//
//  ChannelViewModel.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftTwitch

class ChannelViewModel: ObservableObject {
    
    @Published var channel: Channel
    @Published var status: RequestStatus = .none
    
    @Published var lastVideos: [VideoData] = []
    @Published var fetchVideosStatus: RequestStatus = .none
    
    @Published var lastClips: [ClipData] = []
    
    
    struct Channel {
        var channelInfo: Follow
        var followerCount: Int
    }
    
    init(channel: Follow) {
        self.channel = Channel(channelInfo: channel, followerCount: 0)
        Task {
            loadAdditionalData()
            loadLastVideos()
            loadLastClips()
        }
    }
    
}




// MARK: - loadAdditionalData function

extension ChannelViewModel {
    func loadAdditionalData() {
        self.status = .startedFetching
        Twitch.Users.getUsersFollows(followerId: nil, followedId: self.channel.channelInfo.userData.userId) { result in
            switch result {
            case .success(let getFollowData):
                self.channel.followerCount = getFollowData.total
                self.status = .doneFetching
            case .failure(let data,_ , let error):
                print(error ?? "error")
                print(String(data: data ?? Data(), encoding: .utf8))
                self.status = .error
            }
        }
    }
}


// MARK: - loadLastVideos function

extension ChannelViewModel {
    func loadLastVideos() {
        self.fetchVideosStatus = .startedFetching
        Twitch.Videos.getVideos(videoIds: nil, userId: self.channel.channelInfo.userData.userId, gameId: nil, first: 10) { result in
            switch result {
            case .success(let getVideosData):
                self.lastVideos = getVideosData.videoData
                self.fetchVideosStatus = .doneFetching
            case .failure(let data,_ , let error):
                print(error ?? "error")
                print(String(data: data ?? Data(), encoding: .utf8))
                self.fetchVideosStatus = .error
            }
        }
    }
}


// MARK: - loadLastCategories function

extension ChannelViewModel {
    func loadLastClips() {
        Twitch.Clips.getClips(broadcasterId: self.channel.channelInfo.userData.userId, gameId: nil, clipIds: nil, startedAt: Calendar.current.date(byAdding: .month, value: -1, to: Date.now), first: 10) { result in
            switch result {
            case .success(let getClipsData):
                self.lastClips = getClipsData.clipData
            case .failure(let data,_ , let error):
                print(error ?? "error")
                print(String(data: data ?? Data(), encoding: .utf8))
            }
        }
    }
}
