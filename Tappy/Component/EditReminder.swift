//
//  Edit Reminder.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 22/07/26.
//

import SwiftUI
import SwiftData

struct EditReminder: View {
    
    let reminder: ReminderData
    @Query private var reminderData: [ReminderData]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    
    @State public var newName: String = ""
    @State private var newStartTime: Date = Date()
    @State private var newEndTime: Date = Date()
    @State private var newDate: Date = Date()
    @State private var newReminderType: String = ""

    init(reminder: ReminderData) {
           self.reminder = reminder
           _newName = State(initialValue: reminder.ReminderName)
           _newStartTime = State(initialValue: reminder.startTime)
           _newEndTime = State(initialValue: reminder.endTime)
           _newDate = State(initialValue: reminder.date)
           _selectedReminderType = State(initialValue: ReminderType(rawValue: reminder.typeReminder) ?? .clockin)
       }
    

    @State private var selectedReminderType: ReminderType = .clockin
    
    
    var body: some View {
        VStack{
            Text("Edit Tap Reminder ok")
            
            ReminderForm(
                name: $newName,
                startTime: $newStartTime,
                endTime: $newEndTime,
                date: $newDate,
                reminderType: $selectedReminderType
            )

            
            Button("Edit Reminder"){
                
                
                reminder.ReminderName = newName
                reminder.startTime = newStartTime
                reminder.endTime = newEndTime
                reminder.date = newDate
                reminder.typeReminder = newReminderType
                reminder.intervalTime = newEndTime.timeIntervalSince(newStartTime)
                
                
                try? context.save()
                
                
                dismiss()
                
            }
            
        }.padding(.top, 20)
        
        
    }
}

#Preview {
    EditReminder(reminder: ReminderData(
        name: "Preview Reminder",
        intervalTime: 0,
        startTime: .now,
        endTime: .now,
        date: .now,
        typeReminder: "clockin"
    ))
}
