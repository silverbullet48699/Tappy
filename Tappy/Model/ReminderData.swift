//
//  Untitled.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//


import Foundation
import SwiftData


@Model
class ReminderData: Identifiable {
    var id: UUID = UUID()
    var ReminderName: String = ""

    /// Clock in, clock out, or both. Decides how many windows this reminder owns.
    var typeReminder: String = ReminderType.clockin.rawValue

    /// The window the user should tap IN during. Renamed from the old single
    /// start/end pair, so existing reminders keep their times.
    @Attribute(originalName: "startTime") var clockInStart: Date = Date()
    @Attribute(originalName: "endTime") var clockInEnd: Date = Date()

    /// The window the user should tap OUT during. Only used when `typeReminder` is `both`
    /// or `clockout`.
    var clockOutStart: Date = Date()
    var clockOutEnd: Date = Date()

    /// How often to nudge while inside a window.
    var reminderIntervalMinutes: Int = ReminderInterval.fifteen.rawValue

    /// Weekdays this reminder repeats on, stored as `Calendar` weekday numbers (Mon = 2 ... Sat = 7).
    var repeatDayNumbers: [Int] = []

    init(
        id: UUID = UUID(),
        name: String,
        type: ReminderType,
        clockInWindow: ClockWindow,
        clockOutWindow: ClockWindow,
        intervalMinutes: Int,
        repeatDays: Set<Weekday>
    ) {
        self.id = id
        self.ReminderName = name
        self.typeReminder = type.rawValue
        self.clockInStart = clockInWindow.start
        self.clockInEnd = clockInWindow.end
        self.clockOutStart = clockOutWindow.start
        self.clockOutEnd = clockOutWindow.end
        self.reminderIntervalMinutes = intervalMinutes
        self.repeatDayNumbers = repeatDays.map(\.rawValue).sorted()
    }

    // MARK: - Typed accessors

    var reminderType: ReminderType {
        get { ReminderType(rawValue: typeReminder) ?? .clockin }
        set { typeReminder = newValue.rawValue }
    }

    var clockInWindow: ClockWindow {
        get { ClockWindow(start: clockInStart, end: clockInEnd) }
        set { clockInStart = newValue.start; clockInEnd = newValue.end }
    }

    var clockOutWindow: ClockWindow {
        get { ClockWindow(start: clockOutStart, end: clockOutEnd) }
        set { clockOutStart = newValue.start; clockOutEnd = newValue.end }
    }

    var repeatDays: Set<Weekday> {
        get { Set(repeatDayNumbers.compactMap(Weekday.init(rawValue:))) }
        set { repeatDayNumbers = newValue.map(\.rawValue).sorted() }
    }

    var interval: ReminderInterval {
        get { ReminderInterval(rawValue: reminderIntervalMinutes) ?? .fifteen }
        set { reminderIntervalMinutes = newValue.rawValue }
    }

    /// The window for a given tap, or nil when this reminder doesn't cover it.
    func window(for clockType: ClockType) -> ClockWindow? {
        guard reminderType.covers(clockType) else { return nil }
        return clockType == .clockIn ? clockInWindow : clockOutWindow
    }

    /// Windows this reminder actually uses, paired with their tap.
    var activeWindows: [(clockType: ClockType, window: ClockWindow)] {
        reminderType.clockTypes.compactMap { type in
            window(for: type).map { (type, $0) }
        }
    }

    // MARK: - Behaviour

    /// True when this reminder is meant to fire on the given date's weekday.
    func repeats(on date: Date, calendar: Calendar = .current) -> Bool {
        guard let day = Weekday(rawValue: calendar.component(.weekday, from: date)) else { return false }
        return repeatDays.contains(day)
    }

    /// Which tap a scan at `date` should record. For a `both` reminder this is
    /// whichever window the moment falls in — or, outside both, the nearer one —
    /// so a single NFC tag can serve the morning and the evening.
    func resolvedClockType(at date: Date = Date(), calendar: Calendar = .current) -> ClockType {
        switch reminderType {
        case .clockin: return .clockIn
        case .clockout: return .clockOut
        case .both:
            if clockInWindow.contains(date, calendar: calendar) { return .clockIn }
            if clockOutWindow.contains(date, calendar: calendar) { return .clockOut }
            let toIn = clockInWindow.distanceInMinutes(from: date, calendar: calendar)
            let toOut = clockOutWindow.distanceInMinutes(from: date, calendar: calendar)
            return toIn <= toOut ? .clockIn : .clockOut
        }
    }

    /// Every nudge Tappy owes the user on a repeat day, across all its windows.
    var allReminderTimes: [(clockType: ClockType, times: [Date])] {
        activeWindows.map { ($0.clockType, $0.window.reminderTimes(everyMinutes: reminderIntervalMinutes)) }
    }

    // MARK: - Display

    /// "Both · Weekdays" — shown in the list and as the Shortcuts subtitle.
    var scheduleSummary: String {
        "\(reminderType.displayName) · \(repeatDays.summary)"
    }

    /// "09:00 – 09:30, 17:00 – 18:00"
    var windowSummary: String {
        activeWindows.map(\.window.summary).joined(separator: ", ")
    }

    var intervalSummary: String {
        "Every \(interval.displayName)"
    }
}
