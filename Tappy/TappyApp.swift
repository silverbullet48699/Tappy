//
//  TappyApp.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct TappyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Keep the reminder list Shortcuts offers in sync on launch.
                    TappyShortcuts.updateAppShortcutParameters()
                }
        }
        .modelContainer(TappyDataManager.sharedContainer)
    }
}
