//
//  Enums.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 28/12/2022.
//

import Foundation
import SwiftTwitch

enum RequestStatus: String, Error {
    case none = "Nothing has happend yet... please do something"
    case startedFetching = "Fetching subscriptions data"
    case doneFetching = "Fetch was successful"
    case error = "Unknown error"
}

struct FollowList {
    var follows: [Follow]
    
    /// `total` defines the token that displays the total number of streams from the
    /// `Get Followed Streams` call.
    var total: Int
}

public struct Follow: Hashable {
    var streamData: StreamData?
    var userData: UserData
    var tags: [Tag] = []
}

public struct Tag: Hashable {
    var id: String
    var name: String
    var description: String
}

enum StreamQuality: String, CaseIterable {
    case audio_only
    case q_160p = "160p"
    case q_360p = "360p"
    case q_480p = "480p"
    case q_720p = "720p"
    case q_720p_alt = "720p_alt"
    case q_720p60 = "720p60"
    case q_720p60_alt = "720p60_alt"
    case q_1080p = "1080p"
    case q_1080p60 = "1080p60"
}

extension StreamQuality {
    var formatted: String {
        switch self {
        case .audio_only:
            return "Audio only"
        case .q_160p:
            return "160p"
        case .q_360p:
            return "360p"
        case .q_480p:
            return "480p"
        case .q_720p:
            return "720p"
        case .q_720p_alt:
            return "720p-alt"
        case .q_720p60:
            return "720p60"
        case .q_720p60_alt:
            return "720p60-alt"
        case .q_1080p:
            return "1080p"
        case .q_1080p60:
            return "1080p60 (Source)"
        }
    }
}
