//
//  StaticAndEnums.swift
//  Tappy
//
//  Created by Muhammad Rasya Devansyah on 19/07/26.
//

import Foundation


enum ClockType{
    case clockIn
    case clockOut
}

enum ReminderType: String, CaseIterable, Identifiable {
    case clockin, clockout
    var id: Self { self }
}
