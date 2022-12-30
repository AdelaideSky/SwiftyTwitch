//
//  PictureInPicture.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 30/12/2022.
//

import Cocoa
import SwiftUI




class KeyWindow: NSWindow {
    var appVM: AppViewModel?
    override var canBecomeKey: Bool {
        return true
    }
}

// Handle key events

extension KeyWindow {
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command && event.charactersIgnoringModifiers == "w" {
            if self.appVM != nil {
                self.appVM!.stopPlaying()
            }
            close()
            return
        } else {
            super.keyDown(with: event)
        }
    }
}

extension View {
    private func newPIPWindowInternal(with title: String, isTransparent: Bool = false, appVM: AppViewModel? = nil) -> NSWindow {
        let window = KeyWindow(
            contentRect: NSRect(x: 20, y: 20, width: 480, height: 270),
            styleMask: [.titled, .closable, .resizable, .borderless],
            backing: .buffered,
            defer: false
        )
        window.appVM = appVM

        window.makeKey()
        window.isReleasedWhenClosed = false
        window.title = title
        window.makeKeyAndOrderFront(self)
        window.level = .floating
        window.canBecomeVisibleWithoutLogin = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .canJoinAllApplications, .stationary, .ignoresCycle]
        if isTransparent {
            window.backgroundColor = .clear
            window.isOpaque = false
            window.styleMask = [.hudWindow, .closable, .resizable, .borderless]
            window.isMovableByWindowBackground = true
        }
        window.setIsVisible(true)
        return window
    }

    func newPIPWindow(with title: String = "Twitch PIP Window", isTransparent: Bool = true, appVM: AppViewModel) -> some View {
        let window = newPIPWindowInternal(with: title, isTransparent: isTransparent, appVM: appVM)
        window.contentView = NSHostingView(rootView: self.frame(minWidth: 16*15, minHeight: 9*15))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(self)
        appVM.pictureInPictureWindow = window
        var view: some View {
            Text("Picture In Picture mode active.")
        }
        return view
    }
}
