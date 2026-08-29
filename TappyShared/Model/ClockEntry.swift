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
    /// Which tap this was — always a single clock in or clock out, never "both".
    var clockTypeRaw: String = ClockType.clockIn.rawValue
    var timestamp: Date = Date()
    /// How the entry was created — "shortcut" when an NFC tap ran the App Intent.
    var source: String = "shortcut"

    init(id: UUID = UUID(), reminderID: UUID, reminderName: String, clockType: ClockType, timestamp: Date = Date(), source: String = "shortcut") {
        self.id = id
        self.reminderID = reminderID
        self.reminderName = reminderName
        self.clockTypeRaw = clockType.rawValue
        self.timestamp = timestamp
        self.source = source
    }

    var clockType: ClockType {
        ClockType(rawValue: clockTypeRaw) ?? .clockIn
    }
}
