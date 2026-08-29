//
//  TappyShortcuts.swift
//  Tappy
//
//  Publishes the clock actions to the Shortcuts app and Siri.
//

import AppIntents

struct TappyShortcuts: AppShortcutsProvider {

    static var shortcutTileColor: ShortcutTileColor = .teal

    static var appShortcuts: [AppShortcut] {
        // Naming the reminder parameter inside the phrases is what makes the system
        // fan this out into one shortcut per reminder — "Tap Grab", "Tap Gojek" —
        // instead of a single generic entry. Reminders come from
        // ReminderEntityQuery.suggestedEntities(), refreshed by
        // updateAppShortcutParameters() whenever the list changes.
        //
        // Only this intent is parameterised, and one entry per reminder is enough:
        // it prompts for `both` reminders and logs single-type ones directly.
        // (App Shortcuts are capped at 10 per app, so this leaves room for 10
        // reminders rather than 5.)
        AppShortcut(
            intent: StartClockPromptIntent(),
            phrases: [
                "Tap \(\.$reminder) with \(.applicationName)",
                "\(.applicationName) tap \(\.$reminder)",
                "Clock \(\.$reminder) with \(.applicationName)",
                "Log \(\.$reminder) with \(.applicationName)"
            ],
            shortTitle: "Tap Card",
            systemImageName: "wave.3.right.circle.fill"
        )
    }
}
