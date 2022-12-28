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

public struct Follow {
    var streamData: StreamData?
    var userData: UserData
}
