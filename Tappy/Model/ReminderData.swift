//
//  Untitled.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//


import Foundation
import SwiftData


@Model
class ReminderData {
    
    var name: String
    var intervalTime: Date
    var startTime: Date
    var endTime: Date
    var date: Date
    var typeReminder: String
    
    init(name: String, intervalTime: Date, startTime: Date, endTime: Date, date: Date, typeReminder: String) {
        self.name = name
        self.intervalTime = intervalTime
        self.startTime = startTime
        self.endTime = endTime
        self.date = date
        self.typeReminder = typeReminder
    }
    
}
