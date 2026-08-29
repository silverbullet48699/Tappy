//
//  ClockPromptAttributes.swift
//  Tappy
//
//  Shared between the app and the widget extension. Describes the Live Activity
//  that asks "was that a clock in or a clock out?" after an NFC tap.
//

import ActivityKit
import Foundation

struct ClockPromptAttributes: ActivityAttributes {

    /// The part that changes while the activity is on screen.
    struct ContentState: Codable, Hashable {
        /// Tappy's time-of-day guess. Pre-highlighted so the common case is one tap.
        var suggested: ClockType
        /// Nil while Tappy is still waiting for the user to choose.
        var resolved: ClockType?
        var loggedAt: Date?

        var isAwaitingChoice: Bool { resolved == nil }
    }

    // Fixed for the life of the activity.
    var reminderID: UUID
    var reminderName: String
    var clockInWindowSummary: String
    var clockOutWindowSummary: String

    func windowSummary(for clockType: ClockType) -> String {
        clockType == .clockIn ? clockInWindowSummary : clockOutWindowSummary
    }
}
