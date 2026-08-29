//
//  Weekday.swift
//  Tappy
//
//  Which days a reminder repeats on.
//

import Foundation

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

