//
//  PlayerViewModel.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftTwitch
import Alamofire
import SwiftyJSON
import AVKit
import SwiftUI

class PlayerViewModel: ObservableObject {
    
    @Published var theaterMode: Bool = false
    @Published var fullScreen: Bool = false
    @Published var pictureInPicture: Bool = false
    
    @Published var channel: Follow
    @Published var status: RequestStatus = .none
    
    @Published var streams: [StreamQuality:URL] = [:]
    @Published var selectedStream: StreamQuality? = nil
    
    @Published var player: AVPlayer? = nil
    
    @Published var isPlaying: Bool = false
    
    var refreshTimer: Timer? = nil
    
    var avassetDelegate: AVAssetDelegate = AVAssetDelegate()
    
    struct Channel {
        var channelInfo: Follow
        var followerCount: Int
    }
    
    init(channel: Follow) {
        self.channel = channel
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(30), repeats: true, block: { _ in
            print("refreshing...")
            self.refreshData()
        })
        Task {
            loadPlayer()
            
        }
    }
    //TODO: make custom AVAssetResourceLoaderDelegate to remove ads.
    class AVAssetDelegate: NSObject, AVAssetResourceLoaderDelegate {
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            let request: URLRequest = loadingRequest.request
            let url: URL = request.url!
//            let scheme: String = url.scheme!
            
//            if let _ = loadingRequest.contentInformationRequest {
//                return handleContentInformationRequest(request: loadingRequest)
//            } else if let _ = loadingRequest.dataRequest {
//                return handleDataRequest(request: loadingRequest)
//            } else {
//                return false
//            }
             
            return false
        }
    }
    
}

extension PlayerViewModel {
    func refreshData() {
        Twitch.Streams.getStreams(first: 1, userIds: [self.channel.userData.userId]) { result in
            switch result {
            case .success(let getStreamData):
                if self.channel.streamData != getStreamData.streamData.first! {
                    self.channel.streamData!.viewerCount = getStreamData.streamData.first!.viewerCount
                    self.channel.streamData!.title = getStreamData.streamData.first!.title
                    self.channel.streamData!.communityIds = getStreamData.streamData.first!.communityIds
                    self.channel.streamData!.gameName = getStreamData.streamData.first!.gameName
                    self.channel.streamData!.gameId = getStreamData.streamData.first!.gameId
                }
            case .failure(let data,_ , let error):
                print(error ?? "error")
                print(String(data: data ?? Data(), encoding: .utf8))
            }
            
        }
    }
}

extension PlayerViewModel {
    func loadStream() {
        let request = AF.request("https://pwn.sh/tools/streamapi.py", method: .get, parameters: ["url":"twitch.tv/\(self.channel.userData.userLoginName)"])
        request.responseData() { response in
            if response.data != nil {
                do {
                    let json = try JSON(data: response.data!)
                    var answer: [StreamQuality:URL] = [:]
                    for quality in json["urls"].dictionaryValue.keys {
                        // answer[StreamQuality(rawValue: quality)!] = URL(string: json["urls"][quality].stringValue.replacingOccurrences(of: "https", with: "twitchStream"))!
                        answer[StreamQuality(rawValue: quality)!] = URL(string: json["urls"][quality].stringValue)!
                        
                    }
                    self.streams = answer
                    print(self.streams)
                } catch {print("error streams")}
            }
        }
    }
}

extension PlayerViewModel {
    func loadPlayerItem() {
        if !self.streams.isEmpty {
            self.selectedStream = self.streams.keys.filter( {$0 != .audio_only && $0 != .q_160p && $0 != .q_360p} ).first!
            var asset = AVURLAsset(url: self.streams[selectedStream!]!)
            asset.resourceLoader.setDelegate(avassetDelegate, queue: .init(label: "swiftytwitch.streamDelegate"))
            self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["availableMediaCharacteristicsWithMediaSelectionOptions"]))
//            self.player = AVPlayer(url: self.streams[selectedStream!]!)
//            self.player?.seek(to: CMTimeMakeWithSeconds(15.169, preferredTimescale: 60000))
            self.player?.play()
            self.isPlaying = true
            
        }
    }
    func changeQuality() {
        if !self.streams.isEmpty {
            print("changing...")
            self.player?.replaceCurrentItem(with: AVPlayerItem(url: self.streams[selectedStream!]!))
        }
    }
    func changeQuality2() {
        if !self.streams.isEmpty {
            self.player?.replaceCurrentItem(with: AVPlayerItem(url: self.streams[.audio_only]!))
        }
    }
    func getPlayerView() -> AVPlayerView {
        let view = AVPlayerView()
        view.player = self.player
        view.controlsStyle = .none
        return view
    }
}

extension PlayerViewModel {
    func loadPlayer() {
        let request = AF.request("https://pwn.sh/tools/streamapi.py", method: .get, parameters: ["url":"twitch.tv/\(self.channel.userData.userLoginName)"])
        request.responseData() { response in
            if response.data != nil {
                do {
                    let json = try JSON(data: response.data!)
                    var answer: [StreamQuality:URL] = [:]
                    for quality in json["urls"].dictionaryValue.keys {
                        //answer[StreamQuality(rawValue: quality)!] = URL(string: json["urls"][quality].stringValue.replacingOccurrences(of: "https", with: "twitchStream"))!
                        answer[StreamQuality(rawValue: quality)!] = URL(string: json["urls"][quality].stringValue)!
                    }
                    self.streams = answer
                    self.loadPlayerItem()
                } catch {print("error streams")}
            }
        }
    }
}

extension PlayerViewModel {
    //TODO: add tags - need to do a custom implementation in the 
    func loadTags() {
        var parameters: String
        let request = AF.request("https://api.twitch.tv/helix/tags/streams", method: .get, parameters: ["url":""])
        request.responseData() { response in
            if response.data != nil {
                do {
                    let json = try JSON(data: response.data!)
                    var answer: [StreamQuality:URL] = [:]
                    for quality in json["urls"].dictionaryValue.keys {
                        //answer[StreamQuality(rawValue: quality)!] = URL(string: json["urls"][quality].stringValue.replacingOccurrences(of: "https", with: "twitchStream"))!
                        answer[StreamQuality(rawValue: quality)!] = URL(string: json["urls"][quality].stringValue)!
                    }
                    self.streams = answer
                    self.loadPlayerItem()
                } catch {print("error streams")}
            }
        }
        TwitchTokenManager.shared.accessToken
        
    }
}
