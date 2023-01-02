//
//  StreamNowPlayableBehaviour.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 02/01/2023.
//

import Foundation
import MediaPlayer

class StreamNowPlayableBehavior: NowPlayable {
    
    var defaultAllowsExternalPlayback: Bool { return true }
    
    var defaultRegisteredCommands: [NowPlayableCommand] {
        return [.togglePausePlay,
                .play,
                .pause
        ]
    }
    
    var defaultDisabledCommands: [NowPlayableCommand] {
        
        // By default, no commands are disabled.
        
        return []
    }
    
    func handleNowPlayableConfiguration(commands: [NowPlayableCommand],
                                        disabledCommands: [NowPlayableCommand],
                                        commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus,
                                        interruptionHandler: @escaping (NowPlayableInterruption) -> Void) throws {
        
        // Use the default behavior for registering commands.
        
        try configureRemoteCommands(commands, disabledCommands: disabledCommands, commandHandler: commandHandler)
    }
    
    func handleNowPlayableSessionStart() {
        
        // Set the playback state.
        
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func handleNowPlayableSessionEnd() {
        
        // Set the playback state.
        
        MPNowPlayingInfoCenter.default().playbackState = .stopped
    }
    
    func handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata) {
        
        // Use the default behavior for setting player item metadata.
        
        setNowPlayingMetadata(metadata)
    }
    
    func handleNowPlayablePlaybackChange(playing isPlaying: Bool, metadata: NowPlayableDynamicMetadata) {
        
        // Start with the default behavior for setting playback information.
        
        setNowPlayingPlaybackInfo(metadata)
        
        // Then set the playback state, too.
        
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused

    }
    
}
