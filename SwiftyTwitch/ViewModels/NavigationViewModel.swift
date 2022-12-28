//
//  NavigationViewModel.swift
//  SwiftyYouTube
//
//  Created by Adélaïde Sky on 24/12/2022.
//

import SwiftUI
import SwiftTwitch

public struct Follow {
    var streamData: StreamData?
    var userData: UserData
}

class NavigationViewModel: ObservableObject {
    
    @Published var followList: FollowList = FollowList(follows: [], total: 0)
    @Published var status: RequestStatus = .none
    @Published var loadOtherSubStatus: RequestStatus = .none
    
    var nextPageToken: String? = nil


    
    struct FollowList {
        var follows: [Follow]
        
        /// `total` defines the token that displays the total number of streams from the
        /// `Get Followed Streams` call.
        var total: Int
    }
    
    
    enum RequestStatus: String, Error {
        case none = "Nothing has happend yet... please do something"
        case startedFetching = "Fetching subscriptions data"
        case doneFetching = "Fetch was successful"
        case error = "Unknown error"
    }
    func loadFollowList(userID: String) {
        self.status = .startedFetching
        Twitch.Streams.getFollowedStreams(userID: userID, limit: 10) { result in
            switch result {
                case .success(let getUsersFollowsData):
                print(getUsersFollowsData)
                    for follow in getUsersFollowsData.streamData {
                        Twitch.Users.getUsers(userIds: [], userLoginNames: [follow.streamerLoginName]) { result in
                            switch result {
                                case .success(let getUserData):
                                    print(getUserData)
                                self.followList.follows.append(Follow(streamData: follow, userData: getUserData.userData.first!))
                                print(self.followList.follows)
                                case .failure(let data,_ , let error):
                                    print(error ?? "error")
                                    print(String(data: data ?? Data(), encoding: .utf8))
                                    self.status = .error
                            }
                        }
                    }
                Twitch.Users.getUsersFollows(followerId: userID, followedId: nil, first: 10) { result in
                    switch result {
                        case .success(let getUserFollows):
                            print(getUserFollows.total)
                            self.followList.total = getUserFollows.total
                        for i in 0...(5-getUsersFollowsData.streamData.count) {
                            if !getUsersFollowsData.streamData.contains(where: {$0.streamerId == getUserFollows.followData[i].followedUserId}) {
                                Twitch.Users.getUsers(userIds: [getUserFollows.followData[i].followedUserId], userLoginNames: []) { result in
                                    switch result {
                                        case .success(let getUserData):
                                            print(getUserData)
                                        self.followList.follows.append(Follow(streamData: nil, userData: getUserData.userData.first!))
                                        print(self.followList.follows)
                                        case .failure(let data,_ , let error):
                                            print(error ?? "error")
                                            print(String(data: data ?? Data(), encoding: .utf8))
                                            self.status = .error
                                    }
                                }
                            }
                        }
                        case .failure(let data,_ , let error):
                            print(error ?? "error")
                            print(String(data: data ?? Data(), encoding: .utf8))
                            self.status = .error
                    }
                }
                    self.status = .doneFetching
                case .failure(let data,_ , let error):
                    print(error ?? "error")
                    print(String(data: data ?? Data(), encoding: .utf8))
                    self.status = .error
            }
        }
        
    }
    func loadRemaingSubscriptions() {
        
    }
    func showLessSubscriptions() {
        self.loadOtherSubStatus = .none
    }
}

