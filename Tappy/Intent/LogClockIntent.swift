//
//  LogClockIntent.swift
//  Tappy
//
//  The action a reminder's generated shortcut runs. The user wires this to an
//  NFC automation in Shortcuts; tapping the card documents the clock in/out.
//

import AppIntents
import Foundation

struct LogClockIntent: AppIntent {

    static var title: LocalizedStringResource = "Log Clock In or Out"
    static var description = IntentDescription(
        "Documents a clock in or clock out for one of your Tappy reminders. Attach this to an NFC tag automation so tapping your card records it.",
        categoryName: "Reminders"
    )

    /// Silent by default — an NFC tap should not yank the user into the app.
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Reminder")
    var reminder: ReminderEntity

    @Parameter(
        title: "Action",
        description: "Leave empty and Tappy picks Clock In or Clock Out based on which window you're in."
    )
    var action: ClockType?

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$action) for \(\.$reminder)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        guard let stored = try TappyDataManager.reminder(with: reminder.id) else {
            throw LogClockError.reminderNotFound(reminder.name)
        }

        // With one NFC tag on a "both" reminder, the time of day decides which
        // half of the day this tap belongs to.
        let clockType = action ?? stored.resolvedClockType()

        guard stored.reminderType.covers(clockType) else {
            throw LogClockError.actionNotCovered(reminder: stored.ReminderName, action: clockType.displayName)
        }

        let entry = try TappyDataManager.logClock(for: stored, clockType: clockType)

        let time = entry.timestamp.formatted(date: .omitted, time: .shortened)
        let message = "\(clockType.displayName) for \(stored.ReminderName) at \(time)."

        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

enum LogClockError: Error, CustomLocalizedStringResourceConvertible {
    case reminderNotFound(String)
    case actionNotCovered(reminder: String, action: String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .reminderNotFound(let name):
            return "The reminder \(name) no longer exists in Tappy. Open Tappy and pick a reminder again."
        case .actionNotCovered(let reminder, let action):
            return "\(reminder) isn't set up for \(action). Change its type in Tappy, or pick a different action."
        }
    }
}
