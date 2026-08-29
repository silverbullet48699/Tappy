//
//  ClockEntry.swift
//  Tappy
//
//  One row of documentation: the moment a reminder's Shortcut actually fired.
//

import Foundation
import SwiftData

@Model
class ClockEntry: Identifiable {
    var id: UUID = UUID()
    /// The reminder this entry documents. Kept as a raw UUID so the entry survives
    /// its reminder being deleted.
    var reminderID: UUID = UUID()
    var reminderName: String = ""
    var typeReminder: String = ReminderType.clockin.rawValue
    var timestamp: Date = Date()
    /// How the entry was created — "shortcut" when an NFC tap ran the App Intent.
    var source: String = "shortcut"

    init(id: UUID = UUID(), reminderID: UUID, reminderName: String, typeReminder: String, timestamp: Date = Date(), source: String = "shortcut") {
        self.id = id
        self.reminderID = reminderID
        self.reminderName = reminderName
        self.typeReminder = typeReminder
        self.timestamp = timestamp
        self.source = source
    }

    var reminderType: ReminderType {
        ReminderType(rawValue: typeReminder) ?? .clockin
    }
}
