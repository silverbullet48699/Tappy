//
//  ReminderType.swift
//  Tappy
//
//  What a reminder covers: one tap, the other, or both.
//

import Foundation

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

