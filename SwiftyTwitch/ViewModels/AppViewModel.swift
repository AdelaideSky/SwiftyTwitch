//
//  AppViewModel.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 26/12/2022.
//

import SwiftUI
import Foundation
import SwiftTwitch
import Alamofire
import SwiftyJSON

class AppViewModel: ObservableObject {
    
    static var shared: AppViewModel {
        AppViewModel()
    }
    
    @AppStorage(StorageStrings.userID) var userID: String = ""
    @AppStorage(StorageStrings.userName) var userName: String = ""
    
    @AppStorage(StorageStrings.theaterMode) var theaterMode: Bool = false
    @AppStorage(StorageStrings.ambianceMode) var ambianceMode: Bool = true
    @AppStorage(StorageStrings.lastSelectedQuality) var lastSelectedQuality: StreamQuality = .q_720p60
    @AppStorage(StorageStrings.chatPanelConfig) var chatPanelConfig: ChatPanelConfig = .right
    
    @Published var authState: authentificationState = .none
    
    @Published var clientID: String = ""
    @Published var accessToken: String = ""
    @Published var userInfos: UserData?
    
    @Published var streamPlayer: PlayerViewModel? = nil
    
    @Published var navigationSelection: AnyHashable? = nil
    
    @Published var pictureInPictureWindow: NSWindow? = nil
    @Published var fullScreenWindow: NSWindow? = nil
    
    private let keychain = KeychainSwift()
    
    enum authentificationState: String {
        case none
        case loggedIn
        case loggedOut
        case error
    }
    
    public func restoreLoginState() {
        let clientID = keychain.get(StorageStrings.clientID)
        let accessToken = keychain.get(StorageStrings.accessToken)

        if clientID == nil || accessToken == nil {
            self.authState = .loggedOut
            return
        } else {
            self.clientID = clientID!
            self.accessToken = accessToken!
            TwitchTokenManager.shared.accessToken = self.accessToken
            TwitchTokenManager.shared.clientID = self.clientID
            self.loadLoggedUserInfos()
            self.authState = .loggedIn
        }
    }
    
    public func loadLoggedUserInfos() {
        print("load infos logged user")
        Twitch.Users.getUsers(userIds: [self.userID], userLoginNames: []) { result in
            switch result {
                case .success(let getUserData):
                self.userInfos = getUserData.userData.first
                
                case .failure(let data,_ , let error):
                    print(error ?? "error")
                    print(String(data: data ?? Data(), encoding: .utf8))
            }
        }
    }
    
    public func logIn() {
        let headers: HTTPHeaders = [
            "Client-ID": self.clientID,
            "Authorization": " Bearer \(self.accessToken)"
        ]
        let task = AF.request("https://id.twitch.tv/oauth2/validate", headers: headers)
        task.responseData { response in
            if let json = try? JSON(data: response.data!) {
                if let name = json["login"].string {
                    self.userID = json["user_id"].string!
                    self.userName = name
                    Task {
                        self.keychain.set(self.clientID, forKey: StorageStrings.clientID)
                        self.keychain.set(self.accessToken, forKey: StorageStrings.accessToken)
                        TwitchTokenManager.shared.accessToken = self.accessToken
                        TwitchTokenManager.shared.clientID = self.clientID
                    }
                    self.authState = .loggedIn
                } else {
                    self.authState = .error
                }
            }
        }
    }
    public func logOut() {
        self.userID = ""
        self.userName = ""
        Task {
            self.keychain.delete(StorageStrings.clientID)
            self.keychain.delete(StorageStrings.accessToken)
        }
        TwitchTokenManager.shared.accessToken = nil
        TwitchTokenManager.shared.clientID = nil
        self.authState = .loggedOut

    }
}

extension AppViewModel {
    func playStream(streamer: Follow) {
        if self.streamPlayer != nil {
            self.streamPlayer!.player?.pause()
            self.streamPlayer!.dontUpdateStreams = true
            self.streamPlayer!.player = nil
            self.streamPlayer = nil
        }
        self.streamPlayer = PlayerViewModel(channel: streamer)
    }
    func stopPlaying() {
        if self.streamPlayer != nil {
            self.streamPlayer!.player?.pause()
            self.streamPlayer!.dontUpdateStreams = true
            self.streamPlayer!.player = nil
            self.streamPlayer = nil
        }
        if self.pictureInPictureWindow != nil {
            self.pictureInPictureWindow!.close()
            if self.streamPlayer != nil {
                self.streamPlayer!.pictureInPicture = false
            }
        }
        if self.fullScreenWindow != nil {
            self.fullScreenWindow!.close()
            if self.streamPlayer != nil {
                self.streamPlayer!.fullScreen = false
            }
        }
    }
}
