//
//  StaticAndEnums.swift
//  Tappy
//
//  Created by Muhammad Rasya Devansyah on 19/07/26.
//

import Foundation


/// A single tap: what one NFC scan actually records.
enum ClockType: String, CaseIterable, Identifiable, Codable {
    case clockIn = "clockin"
    case clockOut = "clockout"

    var id: Self { self }

    var displayName: String {
        switch self {
        case .clockIn: return "Clock In"
        case .clockOut: return "Clock Out"
        }
    }

    var symbolName: String {
        switch self {
        case .clockIn: return "arrow.right.to.line"
        case .clockOut: return "arrow.left.to.line"
        }
    }
}

/// What a reminder covers. `both` means the reminder owns two separate
/// windows — one to tap in, one to tap out.
enum ReminderType: String, CaseIterable, Identifiable, Codable {
    case clockin, clockout, both

    var id: Self { self }

    var displayName: String {
        switch self {
        case .clockin: return "Clock In"
        case .clockout: return "Clock Out"
        case .both: return "Both"
        }
    }

    /// The taps this reminder expects, in the order they happen during a day.
    var clockTypes: [ClockType] {
        switch self {
        case .clockin: return [.clockIn]
        case .clockout: return [.clockOut]
        case .both: return [.clockIn, .clockOut]
        }
    }

    func covers(_ clockType: ClockType) -> Bool {
        clockTypes.contains(clockType)
    }
}

/// The stretch of time the user is supposed to tap in, and inside which
/// Tappy nags them every `reminderIntervalMinutes`.
struct ClockWindow: Equatable {
    var start: Date
    var end: Date

    var isValid: Bool { end > start }

    var duration: TimeInterval { end.timeIntervalSince(start) }

    var summary: String {
        "\(start.formatted(date: .omitted, time: .shortened)) – \(end.formatted(date: .omitted, time: .shortened))"
    }

    /// Minutes-since-midnight for `start`, used to compare a window against "now"
    /// without caring which calendar day either fell on.
    private func minutesIntoDay(_ date: Date, calendar: Calendar) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    /// True when `date`'s time-of-day falls inside this window.
    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        let now = minutesIntoDay(date, calendar: calendar)
        let from = minutesIntoDay(start, calendar: calendar)
        let to = minutesIntoDay(end, calendar: calendar)
        // A window that wraps past midnight (e.g. 22:00 – 02:00).
        return from <= to ? (now >= from && now <= to) : (now >= from || now <= to)
    }

    /// How far `date` sits from this window, in minutes. Zero when inside.
    func distanceInMinutes(from date: Date, calendar: Calendar = .current) -> Int {
        if contains(date, calendar: calendar) { return 0 }
        let now = minutesIntoDay(date, calendar: calendar)
        let from = minutesIntoDay(start, calendar: calendar)
        let to = minutesIntoDay(end, calendar: calendar)
        // Shortest way round a 24-hour clock face.
        func gap(_ a: Int, _ b: Int) -> Int {
            let raw = abs(a - b)
            return min(raw, (24 * 60) - raw)
        }
        return min(gap(now, from), gap(now, to))
    }

    /// Every moment Tappy should nudge inside this window, `interval` minutes apart.
    func reminderTimes(everyMinutes interval: Int) -> [Date] {
        guard isValid, interval > 0 else { return [] }
        var times: [Date] = []
        var cursor = start
        while cursor <= end {
            times.append(cursor)
            guard let next = Calendar.current.date(byAdding: .minute, value: interval, to: cursor) else { break }
            cursor = next
        }
        return times
    }
}

/// Days a reminder can repeat on. Raw values match `Calendar.component(.weekday:)`,
/// where Sunday is 1, so Monday is 2 through Saturday is 7.
enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case monday = 2, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    /// One or two letters for the day chips in the form.
    var shortLabel: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "Th"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }

    var fullName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

extension Set where Element == Weekday {
    static var weekdays: Set<Weekday> { [.monday, .tuesday, .wednesday, .thursday, .friday] }

    /// "Every day", "Weekdays", "Mon, Wed, Fri" — used on the reminder list and in Shortcuts.
    var summary: String {
        if isEmpty { return "Never" }
        if count == Weekday.allCases.count { return "Every day" }
        if self == Set<Weekday>.weekdays { return "Weekdays" }
        return Weekday.allCases
            .filter { contains($0) }
            .map { String($0.fullName.prefix(3)) }
            .joined(separator: ", ")
    }
}

/// How often Tappy nudges while inside a window.
enum ReminderInterval: Int, CaseIterable, Identifiable {
    case five = 5, ten = 10, fifteen = 15, twenty = 20, thirty = 30, fortyFive = 45, hour = 60

    var id: Int { rawValue }

    var displayName: String {
        rawValue < 60 ? "\(rawValue) min" : "1 hour"
    }
}
