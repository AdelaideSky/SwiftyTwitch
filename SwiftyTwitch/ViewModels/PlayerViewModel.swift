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
    
    struct Channel {
        var channelInfo: Follow
        var followerCount: Int
    }
    
    init(channel: Follow) {
        self.channel = channel
        Task {
            loadPlayer()
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
                        answer[StreamQuality(rawValue: quality)!] = json["urls"][quality].url!
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
            self.player = AVPlayer(url: self.streams[selectedStream!]!)
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
                        answer[StreamQuality(rawValue: quality)!] = json["urls"][quality].url!
                    }
                    self.streams = answer
                    self.loadPlayerItem()
                } catch {print("error streams")}
            }
        }
    }
}
