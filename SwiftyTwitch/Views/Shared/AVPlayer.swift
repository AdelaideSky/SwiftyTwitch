//
//  AVPlayer.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 29/12/2022.
//

import Foundation
import SwiftUI
import AVFoundation

struct CustomPlayerView: NSViewRepresentable {
    var player: AVPlayer
  func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<CustomPlayerView>) {
  }

  func makeNSView(context: Context) -> NSView {
      return PlayerNSView(frame: .zero, player: player)
  }
}
class PlayerNSView: NSView {
  private let playerLayer = AVPlayerLayer()

    init(frame: CGRect, player: AVPlayer) {
        super.init(frame: frame)
        
        playerLayer.player = player
        if layer == nil{
            layer = CALayer()
        }
        layer?.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layout() {
        super.layout()
        playerLayer.frame = bounds
    }
}
