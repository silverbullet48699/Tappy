//
//  ClockType.swift
//  Tappy
//
//  A single tap: what one NFC scan records.
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

