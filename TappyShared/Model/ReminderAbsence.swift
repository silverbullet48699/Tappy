//
//  ReminderAbsence.swift
//  Tappy
//
//  Marks one reminder as skipped on one day — a holiday, sick leave, or any day
//  the user isn't going in. Recorded rather than inferred, so the calendar can
//  tell "day off" apart from "forgot to tap".
//

import Foundation
import SwiftData

@Model
class ReminderAbsence: Identifiable {
    var id: UUID = UUID()
    /// Raw UUID rather than a relation, so the record survives its reminder
    /// being deleted — same reasoning as ClockEntry.
    var reminderID: UUID = UUID()
    /// Always normalised to the start of the day, so lookups are exact.
    var dayStart: Date = Date()
    var createdAt: Date = Date()

    init(id: UUID = UUID(), reminderID: UUID, dayStart: Date, createdAt: Date = Date()) {
        self.id = id
        self.reminderID = reminderID
        self.dayStart = dayStart
        self.createdAt = createdAt
    }
}
