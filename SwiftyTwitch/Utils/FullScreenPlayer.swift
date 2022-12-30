//
//  FullScreenPlayer.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 30/12/2022.
//

import Foundation
import SwiftUI
import Cocoa

extension View {
    private func newFSWindowInternal(with title: String, isTransparent: Bool = false, appVM: AppViewModel? = nil) -> NSWindow {
        let window = KeyWindow(
            contentRect: NSRect(x: 20, y: 20, width: 480, height: 270),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.appVM = appVM

        let screenFrame = NSScreen.main?.frame
        window.makeKey()
        window.isReleasedWhenClosed = false
        window.setFrame(screenFrame!, display: true)
        window.collectionBehavior = [.fullScreenPrimary]
        
        if isTransparent {
            window.backgroundColor = .clear
            window.isOpaque = false
            window.styleMask = [.borderless]
            window.isMovableByWindowBackground = true
        }
        
        window.setIsVisible(true)
        return window
    }

    func newFullScreenWindow(with title: String = "Twitch PIP Window", isTransparent: Bool = true, appVM: AppViewModel) {
        let window = newFSWindowInternal(with: title, isTransparent: isTransparent, appVM: appVM)
        window.contentView = NSHostingView(rootView: self)
        NSApp.activate(ignoringOtherApps: true)
        window.toggleFullScreen(self)
        window.makeKeyAndOrderFront(self)
        appVM.fullScreenWindow = window
    }
}
