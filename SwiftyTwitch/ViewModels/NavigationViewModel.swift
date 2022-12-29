//
//  NavigationViewModel.swift
//  SwiftyYouTube
//
//  Created by Adélaïde Sky on 24/12/2022.
//

import SwiftUI
import SwiftTwitch

class NavigationViewModel: ObservableObject {
    
    @Published var followList: FollowList = FollowList(follows: [], total: 0)
    @Published var topStreams: [Follow] = []
    @Published var status: RequestStatus = .none
    @Published var loadMoreFollowsStatus: RequestStatus = .none
    @Published var loadTopStreamsStatus: RequestStatus = .none

    var nextPageToken: String? = nil
}



// MARK: - loadFollowList func


extension NavigationViewModel {
    func loadFollowList(userID: String) {
        self.status = .startedFetching
        Twitch.Streams.getFollowedStreams(userID: userID, limit: 50) { result in
            switch result {
                case .success(let getUsersFollowsData):
                    for follow in getUsersFollowsData.streamData {
                        Twitch.Users.getUsers(userIds: [], userLoginNames: [follow.streamerLoginName]) { result in
                            switch result {
                                case .success(let getUserData):
                                self.followList.follows.append(Follow(streamData: follow, userData: getUserData.userData.first!))
                                case .failure(let data,_ , let error):
                                    print(error ?? "error")
                                    print(String(data: data ?? Data(), encoding: .utf8))
                                    self.status = .error
                            }
                        }
                    }
                if getUsersFollowsData.streamData.count < 7 {
                    Twitch.Users.getUsersFollows(followerId: userID, followedId: nil, first: 6-(getUsersFollowsData.streamData.count-1)) { result in
                        switch result {
                        case .success(let getUserFollows):
                            self.followList.total = getUserFollows.total
                            self.nextPageToken = getUserFollows.paginationData?.token
                            for follow in getUserFollows.followData {
                                if !getUsersFollowsData.streamData.contains(where: {$0.streamerId == follow.followedUserId}) {
                                    Twitch.Users.getUsers(userIds: [follow.followedUserId], userLoginNames: []) { result in
                                        switch result {
                                        case .success(let getUserData):
                                            if self.followList.follows.count < 7 {
                                                self.followList.follows.append(Follow(streamData: nil, userData: getUserData.userData.first!))
                                            }
                                        case .failure(let data,_ , let error):
                                            print(error ?? "error")
                                            print(String(data: data ?? Data(), encoding: .utf8))
                                            self.status = .error
                                        }
                                    }
                                }
                            }
                            self.status = .doneFetching
                        case .failure(let data,_ , let error):
                            print(error ?? "error")
                            print(String(data: data ?? Data(), encoding: .utf8))
                            self.status = .error
                        }
                    }
                } else {
                    Twitch.Users.getUsersFollows(followerId: userID, followedId: nil, first: 1) { result in
                        switch result {
                        case .success(let getUserFollows):
                            self.followList.total = getUserFollows.total
                            self.status = .doneFetching
                        case .failure(let data,_ , let error):
                            print(error ?? "error")
                            print(String(data: data ?? Data(), encoding: .utf8))
                            self.status = .error
                        }
                    }
                }
                case .failure(let data,_ , let error):
                    print(error ?? "error")
                    print(String(data: data ?? Data(), encoding: .utf8))
                    self.status = .error
            }
        }
        
    }
}






// MARK: - Load more/less follows funcs


extension NavigationViewModel {
    func loadMoreFollows(userID: String) {
        self.loadMoreFollowsStatus = .startedFetching
        Twitch.Users.getUsersFollows(followerId: userID, followedId: nil, after: nextPageToken, first: 12) { result in
            switch result {
                case .success(let getUserFollows):
                    self.followList.total = getUserFollows.total
                for follow in getUserFollows.followData {
                    if !self.followList.follows.contains(where: {$0.userData.userId == follow.followedUserId}) {
                        Twitch.Users.getUsers(userIds: [follow.followedUserId], userLoginNames: []) { result in
                            switch result {
                                case .success(let getUserData):
                                self.nextPageToken = getUserFollows.paginationData?.token
                                self.followList.follows.append(Follow(streamData: nil, userData: getUserData.userData.first!))
                                if self.loadMoreFollowsStatus == .startedFetching {
                                    self.loadMoreFollowsStatus = .doneFetching
                                }
                                case .failure(let data,_ , let error):
                                    print(error ?? "error")
                                    print(String(data: data ?? Data(), encoding: .utf8))
                                    self.loadMoreFollowsStatus = .error
                            }
                        }
                    }
                }
                
                case .failure(let data,_ , let error):
                    print(error ?? "error")
                    print(String(data: data ?? Data(), encoding: .utf8))
                    self.loadMoreFollowsStatus = .error
            }
        }
    }
    func showLessFollows() {
        self.followList.follows = Array(self.followList.follows.prefix(7))
    }
}


// MARK: - loadTopStreams func


extension NavigationViewModel {
    func loadTopStreams() {
        self.loadTopStreamsStatus = .startedFetching
        Twitch.Streams.getStreams(first: 7) { result in
            switch result {
            case .success(let getStreamsData):
                for stream in getStreamsData.streamData {
                    Twitch.Users.getUsers(userIds: [stream.streamerId], userLoginNames: []) { result in
                        switch result {
                        case .success(let getUserData):
                            self.topStreams.append(Follow(streamData: stream, userData: getUserData.userData.first!))
                        case .failure(let data,_ , let error):
                            print(error ?? "error")
                            print(String(data: data ?? Data(), encoding: .utf8))
                            self.loadTopStreamsStatus = .error
                        }
                    }
                }
                self.loadTopStreamsStatus = .doneFetching
            case .failure(let data,_ , let error):
                print(error ?? "error")
                print(String(data: data ?? Data(), encoding: .utf8))
                self.loadTopStreamsStatus = .error
            }
                
        }
    }
}



// MARK: - quietFollowRefresh func


extension NavigationViewModel {
    func quietFollowRefresh(userID: String) {
        Twitch.Streams.getFollowedStreams(userID: userID, limit: 50) { result in
            switch result {
                case .success(let getUsersFollowsData):
                    for follow in getUsersFollowsData.streamData {
                        Twitch.Users.getUsers(userIds: [], userLoginNames: [follow.streamerLoginName]) { result in
                            switch result {
                                case .success(let getUserData):
                                if !self.followList.follows.contains(where: { $0 == Follow(streamData: follow, userData: getUserData.userData.first!) ? true : false}) {
                                    if !self.followList.follows.contains(where: { $0.userData.userId == getUserData.userData.first!.userId ? true : false}) {
                                        self.followList.follows[self.followList.follows.lastIndex(where: { $0.streamData == nil ? true : false})!] = Follow(streamData: follow, userData: getUserData.userData.first!)
                                    } else {
                                        self.followList.follows[self.followList.follows.firstIndex(where: { $0.userData.userId == getUserData.userData.first!.userId ? true : false})!] = Follow(streamData: follow, userData: getUserData.userData.first!)
                                    }
                                }
                                case .failure(let data,_ , let error):
                                    print(error ?? "error")
                                    print(String(data: data ?? Data(), encoding: .utf8))
                            }
                        }
                    }
                case .failure(let data,_ , let error):
                    print(error ?? "error")
                    print(String(data: data ?? Data(), encoding: .utf8))
                    self.status = .error
            }
        }
        
    }
}


// MARK: - quietTopStreamsRefresh func


extension NavigationViewModel {
    func quietTopStreamsRefresh() {
        Twitch.Streams.getStreams(first: 7) { result in
            switch result {
            case .success(let getStreamsData):
                for index in 0...6 {
                    Twitch.Users.getUsers(userIds: [getStreamsData.streamData[index].streamerId], userLoginNames: []) { result in
                        switch result {
                        case .success(let getUserData):
                            self.topStreams[index] = Follow(streamData: getStreamsData.streamData[index], userData: getUserData.userData.first!)
                        case .failure(let data,_ , let error):
                            print(error ?? "error")
                            print(String(data: data ?? Data(), encoding: .utf8))
                        }
                    }
                }
            case .failure(let data,_ , let error):
                print(error ?? "error")
                print(String(data: data ?? Data(), encoding: .utf8))
            }
                
        }
        
    }
}
