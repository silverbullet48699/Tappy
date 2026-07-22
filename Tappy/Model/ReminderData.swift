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
    var ReminderName: String
    var intervalTime: Date
    var startTime: Date
    var endTime: Date
    var date: Date
    var typeReminder: String
    
    init(id: UUID = UUID(), name: String, intervalTime: Date, startTime: Date, endTime: Date, date: Date, typeReminder: String) {
        self.id = id
        self.ReminderName = name
        self.intervalTime = intervalTime
        self.startTime = startTime
        self.endTime = endTime
        self.date = date
        self.typeReminder = typeReminder
    }
    
}
