//
//  SwiftUIView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 20/07/26.
//

import SwiftUI
import SwiftData


struct AddReminder: View {
    
    @Query private var reminderData: [ReminderData]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    
    @State public var newName: String = ""
    @State private var newStartTime: Date = Date()
    @State private var newEndTime: Date = Date()
    @State private var newDate: Date = Date()
    @State private var newReminderType: String = ""


    @State private var selectedReminderType: ReminderType = .clockin
    
    
    var body: some View {
        VStack{
            Text("New Tap Reminder")
            
            ReminderForm(
                name: $newName,
                startTime: $newStartTime,
                endTime: $newEndTime,
                date: $newDate,
                reminderType: $selectedReminderType
                        )
            Button("Add Reminder"){
                let reminderData:
                    ReminderData = ReminderData(id: UUID(),
                    name: newName,
                    intervalTime: 0,
                    startTime: newStartTime,
                    endTime: newEndTime,
                    date: newDate,
                    typeReminder: newReminderType)
              
                
                context.insert(reminderData)
                try? context.save()
                
                
                newName = ""
                newStartTime = Date()
                newEndTime = Date()
                newDate = Date()
                newReminderType = ""
                
                dismiss()
                
                
            }
               
            
           
            
            
            
        }.padding(.top, 20)
        
        
    }
}

#Preview {
    AddReminder()
}
