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
    
    @State public var newName: String = ""
    @State private var newIntervalTime: Date = Date()
    @State private var newStartTime: Date = Date()
    @State private var newEndTime: Date = Date()
    @State private var newDate: Date = Date()
    @State private var newReminderType: String = ""
    
    enum ReminderType: String, CaseIterable, Identifiable {
        case clockin, clockout
        var id: Self { self }
    }


    @State private var selectedReminderType: ReminderType = .clockin
    
    
    var body: some View {
        VStack{
            Text("New Tap Reminder")
            
            Form{
                Section(header: Text("Reminder Name:")){
                    TextField("Enter Reminder", text: .constant(""))
                }
                
                Section(header: Text("Reminder Name:")){
                    TextField("Enter Reminder", text: .constant(""))
                }
                
                DatePicker(
                    "Start Time", selection: $newStartTime, displayedComponents: [.hourAndMinute]
                   )
                DatePicker(
                    "End Time", selection: $newStartTime, displayedComponents: [.hourAndMinute]
                   )
                let newIntervalTime = newEndTime.timeIntervalSince(newStartTime)
                
                DatePicker("Date", selection: .constant(Date()))
                
                
                
                List{
                    Picker(selection: $selectedReminderType, label: Text("Reminder Type")){
                        Text("ClockIn").tag(ReminderType.clockin)
                    }
                }

            }
            Button("Add Reminder"){
                let newReminderData: ReminderData = ReminderData(name: newName, intervalTime: newIntervalTime, startTime: newStartTime, endTime: newEndTime, date: newDate, typeReminder: newReminderType)
            
                context.insert(newReminderData)
            }
               
            
           
            
            
            
        }.padding(.top, 20)
        
        
    }
}

#Preview {
    AddReminder()
}
