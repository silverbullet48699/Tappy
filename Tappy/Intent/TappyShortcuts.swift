//
//  TappyShortcuts.swift
//  Tappy
//
//  Publishes the clock action to the Shortcuts app and Siri. Reminders created
//  in the app show up here as pickable parameters.
//

import AppIntents

struct TappyShortcuts: AppShortcutsProvider {

    static var shortcutTileColor: ShortcutTileColor = .teal

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogClockIntent(),
            phrases: [
                "Log my clock in with \(.applicationName)",
                "Clock in with \(.applicationName)",
                "Clock out with \(.applicationName)",
                "Tap in with \(.applicationName)"
            ],
            shortTitle: "Log Clock",
            systemImageName: "wave.3.right.circle.fill"
        )
    }
}
