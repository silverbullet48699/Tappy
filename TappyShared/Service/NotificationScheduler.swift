//
//  NotificationScheduler.swift
//  Tappy
//
//  Schedules the nudges that fire while a clock-in/clock-out window is open.
//
//  iOS keeps only 64 pending local notifications per app, and a single reminder
//  can easily want more than that — a 5-minute interval over two windows, five
//  days a week, is 130+. So Tappy never tries to schedule the whole week. It
//  schedules a rolling horizon of the soonest nudges and tops the list up on
//  launch, on every reminder edit, and after each tap. Anything already tapped
//  is dropped, so the app stops nagging once you've clocked in.
//

import Foundation
import UserNotifications

@MainActor
enum NotificationScheduler {

    /// Marks the requests Tappy owns, so we never disturb anyone else's.
    nonisolated static let identifierPrefix = "tappy"

    /// The system ceiling is 64; leave headroom rather than racing it.
    nonisolated static let pendingBudget = 55

    /// How far ahead to schedule. Short enough to stay under budget, long enough
    /// to survive a couple of days without the app being opened.
    nonisolated static let horizon: TimeInterval = 48 * 60 * 60

    /// Set by the last refresh so the UI can say when nudges were dropped.
    private(set) static var lastScheduledCount = 0
    private(set) static var lastRequestedCount = 0

    static var lastRefreshWasTruncated: Bool { lastRequestedCount > lastScheduledCount }

    // MARK: - Authorization

    @discardableResult
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("[Tappy] Notification authorization failed: \(error)")
            return false
        }
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    static var isAuthorized: Bool {
        get async {
            switch await authorizationStatus() {
            case .authorized, .provisional, .ephemeral: return true
            default: return false
            }
        }
    }

    // MARK: - Scheduling

    /// Rebuilds the pending list from scratch. Safe to call from anywhere that
    /// changes a reminder or records a tap.
    static func refresh(now: Date = Date(), calendar: Calendar = .current) async {
        let center = UNUserNotificationCenter.current()

        guard await isAuthorized else {
            await clearAll()
            return
        }

        let reminders: [ReminderData]
        let tapped: Set<TapKey>
        let absent: Set<DayKey>
        let windowStart = calendar.startOfDay(for: now)
        let windowEnd = now.addingTimeInterval(horizon)
        do {
            reminders = try TappyDataManager.allReminders()
            tapped = try alreadyTapped(from: windowStart, to: windowEnd, calendar: calendar)
            absent = try daysOff(from: windowStart, to: windowEnd, calendar: calendar)
        } catch {
            print("[Tappy] Could not read reminders while scheduling: \(error)")
            return
        }

        let wanted = plannedNudges(for: reminders, tapped: tapped, absent: absent, now: now, calendar: calendar)
            .sorted { $0.fireDate < $1.fireDate }

        lastRequestedCount = wanted.count
        let scheduled = Array(wanted.prefix(pendingBudget))
        lastScheduledCount = scheduled.count

        // Replace wholesale: simpler than diffing, and cheap at this size.
        await clearAll()
        for nudge in scheduled {
            do {
                try await center.add(nudge.request(calendar: calendar))
            } catch {
                print("[Tappy] Could not schedule nudge \(nudge.identifier): \(error)")
            }
        }
    }

    /// Drops every request Tappy owns, leaving other apps' alone.
    static func clearAll() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix + "|") }
        center.removePendingNotificationRequests(withIdentifiers: ours)
    }

    // MARK: - Building the list

    /// Pure: given reminders and what's already been tapped, works out every nudge
    /// owed inside the horizon. Kept internal so it can be tested without a
    /// notification centre (which needs a real app bundle).
    static func plannedNudges(
        for reminders: [ReminderData],
        tapped: Set<TapKey>,
        absent: Set<DayKey> = [],
        now: Date,
        calendar: Calendar
    ) -> [Nudge] {
        let cutoff = now.addingTimeInterval(horizon)
        var result: [Nudge] = []

        // Walk day by day across the horizon rather than assuming "today+2".
        for offset in 0...(Int(horizon / 86_400) + 1) {
            guard let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)) else { continue }

            for reminder in reminders where reminder.repeats(on: day, calendar: calendar) {
                // A day marked off gets no nudges at all, for either window.
                if absent.contains(DayKey(reminderID: reminder.id, day: day, calendar: calendar)) { continue }

                for (clockType, window) in reminder.activeWindows {
                    // Already clocked in for this day? Then stop nagging about it.
                    if tapped.contains(TapKey(reminderID: reminder.id, clockType: clockType, day: day, calendar: calendar)) {
                        continue
                    }

                    for slot in window.reminderTimes(everyMinutes: reminder.reminderIntervalMinutes) {
                        // The window stores a time of day; re-anchor it onto this day.
                        let parts = calendar.dateComponents([.hour, .minute], from: slot)
                        guard let fireDate = calendar.date(
                            bySettingHour: parts.hour ?? 0, minute: parts.minute ?? 0, second: 0, of: day
                        ) else { continue }

                        guard fireDate > now, fireDate <= cutoff else { continue }

                        result.append(Nudge(
                            reminderID: reminder.id,
                            reminderName: reminder.ReminderName,
                            clockType: clockType,
                            fireDate: fireDate,
                            windowEnd: window.end
                        ))
                    }
                }
            }
        }
        return result
    }

    static func daysOff(from start: Date, to end: Date, calendar: Calendar) throws -> Set<DayKey> {
        let absences = try TappyDataManager.absences(from: start, to: end)
        return Set(absences.map { DayKey(reminderID: $0.reminderID, day: $0.dayStart, calendar: calendar) })
    }

    static func alreadyTapped(from start: Date, to end: Date, calendar: Calendar) throws -> Set<TapKey> {
        let entries = try TappyDataManager.entries(from: start, to: end)
        return Set(entries.map {
            TapKey(reminderID: $0.reminderID, clockType: $0.clockType, day: $0.timestamp, calendar: calendar)
        })
    }
}

// MARK: - Supporting types

/// Identifies "this reminder's clock-in for this day", so a recorded tap can
/// suppress the nudges that were going to chase it.
/// Identifies "this reminder on this day", regardless of which tap.
struct DayKey: Hashable {
    let reminderID: UUID
    let dayStart: Date

    init(reminderID: UUID, day: Date, calendar: Calendar) {
        self.reminderID = reminderID
        self.dayStart = calendar.startOfDay(for: day)
    }
}

struct TapKey: Hashable {
    let reminderID: UUID
    let clockType: ClockType
    let dayStart: Date

    init(reminderID: UUID, clockType: ClockType, day: Date, calendar: Calendar) {
        self.reminderID = reminderID
        self.clockType = clockType
        self.dayStart = calendar.startOfDay(for: day)
    }
}

struct Nudge {
    let reminderID: UUID
    let reminderName: String
    let clockType: ClockType
    let fireDate: Date
    let windowEnd: Date

    var identifier: String {
        "\(NotificationScheduler.identifierPrefix)|\(reminderID.uuidString)|\(clockType.rawValue)|\(Int(fireDate.timeIntervalSince1970))"
    }

    func request(calendar: Calendar) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = reminderName
        let closes = windowEnd.formatted(date: .omitted, time: .shortened)
        content.body = clockType == .clockIn
            ? "Time to tap in — the window closes at \(closes)."
            : "Don't forget to tap out — the window closes at \(closes)."
        content.sound = .default
        content.userInfo = [
            "reminderID": reminderID.uuidString,
            "clockType": clockType.rawValue
        ]

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
    }
}
