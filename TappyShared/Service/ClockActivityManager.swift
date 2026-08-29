//
//  ClockActivityManager.swift
//  Tappy
//
//  Owns the Live Activity that asks which kind of tap just happened.
//
//  The building uses one card for both readers, so an NFC tap can't say on its
//  own whether it was an entry or an exit. Rather than guess, Tappy puts the
//  question in the Dynamic Island and lets the user answer it in place.
//

import ActivityKit
import Foundation

enum ClockActivityManager {

    /// How long a prompt stays up before the system retires it.
    static let promptLifetime: TimeInterval = 60 * 30

    static var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    /// Puts the "clock in or clock out?" prompt on screen for a reminder.
    @discardableResult
    static func startPrompt(for reminder: ReminderData, at date: Date = Date()) throws -> String {
        guard areActivitiesEnabled else { throw ClockActivityError.activitiesDisabled }

        let attributes = ClockPromptAttributes(
            reminderID: reminder.id,
            reminderName: reminder.ReminderName,
            clockInWindowSummary: reminder.clockInWindow.summary,
            clockOutWindowSummary: reminder.clockOutWindow.summary
        )

        // The time-based guess becomes the highlighted default, not the decision.
        let state = ClockPromptAttributes.ContentState(
            suggested: reminder.resolvedClockType(at: date),
            resolved: nil,
            loggedAt: nil
        )

        let activity = try Activity.request(
            attributes: attributes,
            content: ActivityContent(state: state, staleDate: date.addingTimeInterval(promptLifetime)),
            pushType: nil
        )
        return activity.id
    }

    /// Flips the prompt to its answered state, then retires it shortly after so the
    /// user sees the confirmation instead of it vanishing mid-tap.
    static func resolve(activityID: String, as clockType: ClockType, at date: Date = Date()) async {
        guard let activity = Activity<ClockPromptAttributes>.activities.first(where: { $0.id == activityID })
                ?? Activity<ClockPromptAttributes>.activities.first else { return }

        let state = ClockPromptAttributes.ContentState(
            suggested: activity.content.state.suggested,
            resolved: clockType,
            loggedAt: date
        )

        await activity.update(ActivityContent(state: state, staleDate: nil))
        await activity.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .after(date.addingTimeInterval(4)))
    }

    /// Clears any prompt left over from an earlier tap.
    static func endAll() async {
        for activity in Activity<ClockPromptAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}

enum ClockActivityError: Error, LocalizedError {
    case activitiesDisabled

    var errorDescription: String? {
        "Live Activities are turned off for Tappy. Turn them on in Settings › Tappy to get the Dynamic Island prompt."
    }
}
