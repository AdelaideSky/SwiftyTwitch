//
//  PlayerView.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import AVKit
import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    
    var body: some View {
        VStack {
            if playerVM.player != nil {
                VideoPlayer(player: playerVM.player)
            }
        }
    }
}

