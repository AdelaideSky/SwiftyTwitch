//
//  SwiftyTwitchApp.swift
//  SwiftyTwitch
//
//  Created by Adélaïde Sky on 26/12/2022.
//

import SwiftUI
import WhatsNewKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("App finished launching")
    }
}

@main
struct SwiftyTwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Window("Twitch", id: "swiftyTwitch.main") {
            ContentView()
                .environmentObject(AppViewModel.shared)
                .frame(minWidth: 1100, minHeight: 500)
                .environment(
                    \.whatsNew,
                     WhatsNewEnvironment(
                        // Specify in which way the presented WhatsNew Versions are stored.
                        // In default the `UserDefaultsWhatsNewVersionStore` is used.
                        versionStore: UserDefaultsWhatsNewVersionStore(),
                        // Pass a `WhatsNewCollectionProvider` or an array of WhatsNew instances
                        whatsNewCollection: self
                     )
                )
        }
    }
}

// MARK: - App+WhatsNewCollectionProvider

extension SwiftyTwitchApp: WhatsNewCollectionProvider {

    /// Declare your WhatsNew instances per version
    var whatsNewCollection: WhatsNewCollection {
        WhatsNew(
            version: "0.1",
            title: "What's new in SwiftyTwitch",
            features: [
                .init(image: .init(systemName: "swift"), title: "Native experience", subtitle: "A simple Twitch desktop app... In SwiftUI ! Every part of the app is native, allowing better performances and consistency."),
                .init(image: .init(systemName: "pip"), title: "Picture in Picture", subtitle: "Wanna do something else while watching a stream ? Don't worry ! Just enable the Picture in Picture mode to always have your stream in sight !"),
                .init(image: .init(systemName: "xmark.rectangle"), title: "No ads", subtitle: "Shhht ! Don't tell anyone... Even if sometimes you can get ads, you will less likely see those in here !"),
                .init(image: .init(systemName: "lock.open"), title: "Open source", subtitle: "Because transparency is always the best, and because working together is way better than alone, the whole app is open-sourced, free, forever !")
            ]
        )
    }

}
