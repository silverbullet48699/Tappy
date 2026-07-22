//
//  ReminderForm.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 23/07/26.
//

import SwiftUI

struct ReminderForm: View {
    
        @Binding var name: String
        @Binding var startTime: Date
        @Binding var endTime: Date
        @Binding var date: Date
        @Binding var reminderType: ReminderType
    
    
    var body: some View {
        Form{
            Section(header: Text("Reminder Name:")){
               
                TextField(name.isEmpty ? "Enter Reminder" : "", text: $name)
            }
            
            
            DatePicker(
                "Start Time", selection: $startTime, displayedComponents: [.hourAndMinute]
               )
            DatePicker(
                "End Time", selection: $endTime, displayedComponents: [.hourAndMinute]
               )
//                let newIntervalTime = newEndTime.timeIntervalSince(newStartTime)
//
            DatePicker("Date", selection: $date, displayedComponents: [.date])
            
            
            List{
                Picker(selection: $reminderType, label: Text("Reminder Type")){
                    Text("ClockIn").tag(ReminderType.clockin)
                    Text("ClockOut").tag(ReminderType.clockout)
                }
            }

        }

    }
}

//#Preview {
//    ReminderForm(name: <#T##Binding<String>#>, startTime: <#T##Binding<Date>#>, endTime: <#T##Binding<Date>#>, date: <#T##Binding<Date>#>, reminderType: <#T##Binding<ReminderType>#>)
//}
