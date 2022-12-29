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

class PlayerViewModel: ObservableObject {
    
    @Published var channel: Follow
    @Published var status: RequestStatus = .none
    
    @Published var streams: [StreamQuality:URL] = [:]
    
    @Published var player: AVPlayer? = nil
    
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
            self.player = AVPlayer(url: self.streams.first!.value)
            self.player?.isMuted = true
            self.player?.play()
        }
    }
}

extension PlayerViewModel {
    func loadPlayer() {
        if !self.streams.isEmpty {
            loadPlayerItem()
        } else {
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
}
