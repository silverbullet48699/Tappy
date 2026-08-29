//
//  ResolveClockIntent.swift
//  Tappy
//
//  What the Clock In / Clock Out buttons in the Dynamic Island actually run.
//
//  Shared with the widget extension because the extension has to construct this
//  intent to build the buttons. As a `LiveActivityIntent` the system performs it
//  in the app's process, so it writes to the same store the app reads.
//

import AppIntents
import Foundation

struct ResolveClockIntent: LiveActivityIntent {

    static var title: LocalizedStringResource = "Record Clock Choice"
    static var description = IntentDescription("Records the tap the user picked in the Dynamic Island.")

    /// Internal plumbing for the Live Activity buttons — not something to expose
    /// as its own action in the Shortcuts app.
    static var isDiscoverable: Bool = false
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Reminder ID")
    var reminderID: String

    @Parameter(title: "Activity ID")
    var activityID: String

    @Parameter(title: "Action")
    var clockType: ClockType

    init() {}

    init(reminderID: UUID, activityID: String, clockType: ClockType) {
        self.reminderID = reminderID.uuidString
        self.activityID = activityID
        self.clockType = clockType
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: reminderID),
              let reminder = try TappyDataManager.reminder(with: uuid) else {
            // The reminder was deleted while the prompt was on screen; clear it.
            await ClockActivityManager.resolve(activityID: activityID, as: clockType)
            return .result()
        }

        try TappyDataManager.logClock(for: reminder, clockType: clockType, source: "dynamic-island")
        await ClockActivityManager.resolve(activityID: activityID, as: clockType)

        return .result()
    }
}
