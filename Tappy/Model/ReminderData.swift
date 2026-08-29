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
    var intervalTime: TimeInterval = 0
    var startTime: Date = Date()
    var endTime: Date = Date()
    /// Weekdays this reminder repeats on, stored as `Calendar` weekday numbers (Mon = 2 ... Sat = 7).
    var repeatDayNumbers: [Int] = []
    var typeReminder: String = ReminderType.clockin.rawValue

    init(id: UUID = UUID(), name: String, intervalTime: TimeInterval, startTime: Date, endTime: Date, repeatDays: Set<Weekday>, typeReminder: String) {
        self.id = id
        self.ReminderName = name
        self.intervalTime = intervalTime
        self.startTime = startTime
        self.endTime = endTime
        self.repeatDayNumbers = repeatDays.map(\.rawValue).sorted()
        self.typeReminder = typeReminder
    }

    /// Type-safe view over `repeatDayNumbers`.
    var repeatDays: Set<Weekday> {
        get { Set(repeatDayNumbers.compactMap(Weekday.init(rawValue:))) }
        set { repeatDayNumbers = newValue.map(\.rawValue).sorted() }
    }

    var reminderType: ReminderType {
        get { ReminderType(rawValue: typeReminder) ?? .clockin }
        set { typeReminder = newValue.rawValue }
    }

    /// "Clock In · Weekdays" — shown in the list and as the Shortcuts subtitle.
    var scheduleSummary: String {
        "\(reminderType.displayName) · \(repeatDays.summary)"
    }

    /// True when this reminder is meant to fire on the given date's weekday.
    func repeats(on date: Date, calendar: Calendar = .current) -> Bool {
        guard let day = Weekday(rawValue: calendar.component(.weekday, from: date)) else { return false }
        return repeatDays.contains(day)
    }
}
