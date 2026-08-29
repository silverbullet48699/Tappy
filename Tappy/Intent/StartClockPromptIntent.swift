//
//  StartClockPromptIntent.swift
//  Tappy
//
//  The action to attach to the NFC automation when one card serves both readers.
//  Instead of guessing, it raises the Dynamic Island prompt and lets the user say
//  which tap it was.
//

import AppIntents
import Foundation

struct StartClockPromptIntent: LiveActivityIntent {

    static var title: LocalizedStringResource = "Ask Clock In or Clock Out"
    static var description = IntentDescription(
        "Shows a Dynamic Island prompt so you can say whether the tap you just made was a clock in or a clock out. Attach this to your NFC tag when the same card is used for both.",
        categoryName: "Reminders"
    )

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Reminder")
    var reminder: ReminderEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Ask which tap for \(\.$reminder)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        guard let stored = try TappyDataManager.reminder(with: reminder.id) else {
            throw LogClockError.reminderNotFound(reminder.name)
        }

        // A reminder that only covers one action has nothing to ask about.
        guard stored.reminderType == .both else {
            let clockType = stored.resolvedClockType()
            let entry = try TappyDataManager.logClock(for: stored, clockType: clockType, source: "shortcut")
            let message = "\(clockType.displayName) for \(stored.ReminderName) at \(entry.timestamp.formatted(date: .omitted, time: .shortened))."
            return .result(value: message, dialog: IntentDialog(stringLiteral: message))
        }

        // Clear a stale prompt from an earlier tap before raising a new one.
        await ClockActivityManager.endAll()

        do {
            _ = try ClockActivityManager.startPrompt(for: stored)
            let message = "Which one was that? Pick Clock In or Clock Out in the Dynamic Island."
            return .result(value: message, dialog: IntentDialog(stringLiteral: message))
        } catch {
            // Live Activities off: fall back to the time-of-day guess rather than
            // dropping the tap on the floor.
            let clockType = stored.resolvedClockType()
            let entry = try TappyDataManager.logClock(for: stored, clockType: clockType, source: "shortcut-fallback")
            let message = "Live Activities are off, so Tappy logged \(clockType.displayName) for \(stored.ReminderName) at \(entry.timestamp.formatted(date: .omitted, time: .shortened))."
            return .result(value: message, dialog: IntentDialog(stringLiteral: message))
        }
    }
}
