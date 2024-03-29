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
import MediaPlayer

class PlayerViewModel: ObservableObject {
    
    @Published var fullScreen: Bool = false
    @Published var pictureInPicture: Bool = false
    
    @Published var channel: Follow
    @Published var status: RequestStatus = .none
    
    @Published var streams: [StreamQuality:URL] = [:]
    @Published var selectedStream: StreamQuality? = nil
    
    @Published var player: AVPlayer? = nil
    @Published var dontUpdateStreams: Bool = false
    @AppStorage(StorageStrings.lastSelectedQuality) var lastSelectedQuality: StreamQuality = .q_720p60
    
    @Published var isPlaying: Bool = false
    
    @Published var automaticPlay: Bool = true
    
    var refreshTimer: Timer? = nil
    
    @Published var nowPlayable = StreamNowPlayableBehavior()
    
    struct Channel {
        var channelInfo: Follow
        var followerCount: Int
    }
    
    init(channel: Follow) {
        print("init player")
        self.channel = channel
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(60), repeats: true, block: { _ in
            self.refreshData()
        })
        Task {
            loadPlayer()
            
        }
    }
    init(channel: Follow, autoPlay: Bool) {
        print("init player")
        self.channel = channel
        self.automaticPlay = autoPlay
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(60), repeats: true, block: { _ in
            self.refreshData()
        })
        Task {
            loadPlayer()
            
        }
    }
    
    
}

extension PlayerViewModel {
    func refreshData() {
        if AppViewModel.shared.streamPlayer?.channel.userData.userLoginName != self.channel.userData.userLoginName {
            self.refreshTimer?.invalidate()
            return
        }
        print("refreshing for: \(self.channel.userData.userDisplayName)")
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
        let request = AF.request((Constants.apiURL+"/twitch/\(self.channel.userData.userLoginName)"), method: .get)
        request.responseData() { response in
            if response.data != nil {
                do {
                    let json = try JSON(data: response.data!)
                    var answer: [StreamQuality:URL] = [:]
                    for quality in json.dictionaryValue.keys {
                        answer[StreamQuality(rawValue: quality)!] = URL(string: json[quality].stringValue)!
                    }
                    self.streams = answer
                    print(self.streams)
                } catch {
                    print("error streams")
                    self.status = .error
                }
            }
        }
    }
}

extension PlayerViewModel {
    func loadPlayerItem() {
        if !self.streams.isEmpty {
            if (self.streams[self.lastSelectedQuality] != nil) {
                self.selectedStream = self.lastSelectedQuality
            } else {
                self.selectedStream = self.streams.keys.filter( {$0 != .audio_only && $0 != .q_160p && $0 != .q_360p} ).first!
            }
            let item = AVPlayerItem(url: self.streams[selectedStream!]!)
            self.player = AVPlayer(playerItem: item)
//            self.player = AVPlayer(url: self.streams[selectedStream!]!)
//            self.player?.seek(to: CMTimeMakeWithSeconds(15.169, preferredTimescale: 60000))
            if self.automaticPlay {
                self.player?.play()
                self.isPlaying = true
            }
            setupNowPlaying()
            self.nowPlayable.handleNowPlayableSessionStart()
        }
    }
    func changeQuality() {
        if !self.streams.isEmpty {
            self.player?.replaceCurrentItem(with: AVPlayerItem(url: self.streams[selectedStream!]!))
            self.lastSelectedQuality = selectedStream!
        }
    }
    func getPlayerView() -> AVPlayerView {
        let view = AVPlayerView()
        view.player = self.player
        view.controlsStyle = .none
        return view
    }
    func getData(from url: URL, completion: @escaping (NSImage?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let data = data {
                completion(NSImage(data: data))
            }
        })
        .resume()
    }

    func setupNowPlaying() {
        let url = self.channel.userData.profileImageURL
        getData(from: url) { [weak self] image in
            guard let self = self,
                  let downloadedImage = image else {
                return
            }
            let artwork = MPMediaItemArtwork.init(boundsSize: downloadedImage.size, requestHandler: { _ -> NSImage in
                downloadedImage.backgroundColor = .windowBackgroundColor
                downloadedImage.size = CGSize(width: 200, height: 200)
                return downloadedImage
            })
            self.setNowPlayingInfo(with: artwork)
        }
    }
    func setNowPlayingInfo(with artwork: MPMediaItemArtwork) {
        let nowPlayingInfo = NowPlayableStaticMetadata(assetURL: URL(string: "https://twitch.tv/\(self.channel.userData.userLoginName)")!,
                                                       mediaType: .video,
                                                       isLiveStream: true,
                                                       title: self.channel.streamData!.title,
                                                       artist: self.channel.userData.userDisplayName,
                                                       artwork: artwork,
                                                       albumArtist: nil,
                                                       albumTitle: nil)
        do {
            try self.nowPlayable.handleNowPlayableConfiguration(commands: [.play, .pause, .togglePausePlay, .stop], disabledCommands: [], commandHandler: { command, commandEvent in
                switch command {
                case .play:
                    if self.player != nil {
                        self.player!.play()
                        guard let livePosition = self.player!.currentItem?.seekableTimeRanges.last as? CMTimeRange else {
                            return MPRemoteCommandHandlerStatus.commandFailed
                        }
                        self.player!.seek(to: CMTimeRangeGetEnd(livePosition))
                        self.nowPlayable.handleNowPlayablePlaybackChange(playing: true, metadata: NowPlayableDynamicMetadata(rate: 0, position: 0, duration: 0, currentLanguageOptions: [], availableLanguageOptionGroups: []))
                        self.isPlaying = true
                        return MPRemoteCommandHandlerStatus.success
                    } else {
                        return MPRemoteCommandHandlerStatus.noSuchContent
                    }
                case .pause:
                    if self.player != nil {
                        self.player!.pause()
                        self.nowPlayable.handleNowPlayablePlaybackChange(playing: false, metadata: NowPlayableDynamicMetadata(rate: 0, position: 0, duration: 0, currentLanguageOptions: [], availableLanguageOptionGroups: []))
                        self.isPlaying = false
                        return MPRemoteCommandHandlerStatus.success
                    } else {
                        return MPRemoteCommandHandlerStatus.noSuchContent
                    }
                default:
                    return MPRemoteCommandHandlerStatus.commandFailed
                }
            }, interruptionHandler: { _ in
                
            })
            self.nowPlayable.handleNowPlayableSessionStart()
            self.nowPlayable.handleNowPlayableItemChange(metadata: nowPlayingInfo)
        } catch {}
        
      }
}

extension PlayerViewModel {
    func loadPlayer() {
        print("loading.")
        self.status = .none
        let request = AF.request((Constants.apiURL+"/twitch/\(self.channel.userData.userLoginName)"), method: .get)
        request.responseData() { response in
            print("resoponse.")
            if response.data != nil {
                do {
                    let json = try JSON(data: response.data!)
                    var answer: [StreamQuality:URL] = [:]
                    if !self.dontUpdateStreams {
                        if json.count > 1 {
                            for quality in json.dictionaryValue.keys {
                                answer[StreamQuality(rawValue: quality)!] = URL(string: json[quality].stringValue)!
                            }
                            self.streams = answer
                            self.loadPlayerItem()
                        } else {
                            print("error streams: no streams")
                            self.status = .error
                        }
                    }
                    
                } catch {
                    print("error streams: server error.")
                    self.status = .error
                }
            }
        }
    }
}

extension PlayerViewModel {
    //TODO: add tags - need to do a custom implementation in the package
    func loadTags() {
        //var parameters: String
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
        
    }
}
