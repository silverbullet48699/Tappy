//
//  ReminderInterval.swift
//  Tappy
//
//  How often Tappy nudges inside a window.
//

import Foundation

/// How often Tappy nudges while inside a window.
enum ReminderInterval: Int, CaseIterable, Identifiable {
    case five = 5, ten = 10, fifteen = 15, twenty = 20, thirty = 30, fortyFive = 45, hour = 60

    var id: Int { rawValue }

    var displayName: String {
        rawValue < 60 ? "\(rawValue) min" : "1 hour"
    }
}

