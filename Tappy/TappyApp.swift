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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    NotificationPresenter.shared.register()
                    // Keep the reminder list Shortcuts offers in sync on launch.
                    TappyShortcuts.updateAppShortcutParameters()
                    await NotificationScheduler.requestAuthorization()
                    await NotificationScheduler.refresh()
                }
                .onChange(of: scenePhase) { _, phase in
                    // Top the rolling window up whenever the app comes forward.
                    guard phase == .active else { return }
                    Task { await NotificationScheduler.refresh() }
                }
        }
        .modelContainer(TappyDataManager.sharedContainer)
    }
}
