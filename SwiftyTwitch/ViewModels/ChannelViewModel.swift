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
    
    struct Channel {
        var channelInfo: Follow
        var followerCount: Int
    }
    
    init(channel: Follow) {
        self.channel = Channel(channelInfo: channel, followerCount: 0)
        Task {
            loadAdditionalData()
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
