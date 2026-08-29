//
//  LogClockIntent.swift
//  Tappy
//
//  The action a reminder's generated shortcut runs. The user wires this to an
//  NFC automation in Shortcuts; tapping the card documents the clock in/out.
//

import AppIntents
import Foundation

extension ReminderType: AppEnum {
    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation { "Clock Action" }

    nonisolated static var caseDisplayRepresentations: [ReminderType: DisplayRepresentation] { [
        .clockin: DisplayRepresentation(title: "Clock In", image: .init(systemName: "arrow.right.to.line")),
        .clockout: DisplayRepresentation(title: "Clock Out", image: .init(systemName: "arrow.left.to.line"))
    ] }
}

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

    @Parameter(title: "Action", description: "Leave empty to use the reminder's own type.")
    var action: ReminderType?

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$action) for \(\.$reminder)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        guard let stored = try TappyDataManager.reminder(with: reminder.id) else {
            throw LogClockError.reminderNotFound(reminder.name)
        }

        let type = action ?? stored.reminderType
        let entry = try TappyDataManager.logClock(for: stored, type: type)

        let time = entry.timestamp.formatted(date: .omitted, time: .shortened)
        let message = "\(type.displayName) for \(stored.ReminderName) at \(time)."

        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

enum LogClockError: Error, CustomLocalizedStringResourceConvertible {
    case reminderNotFound(String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .reminderNotFound(let name):
            return "The reminder \(name) no longer exists in Tappy. Open Tappy and pick a reminder again."
        }
    }
}
