//
//  ClockWindow.swift
//  Tappy
//
//  The stretch of time a tap is expected in.
//

import Foundation

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

