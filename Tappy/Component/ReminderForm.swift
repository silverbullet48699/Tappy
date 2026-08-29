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
    @Binding var repeatDays: Set<Weekday>
    @Binding var reminderType: ReminderType

    var body: some View {
        Form {
            Section(header: Text("Reminder Name:")) {
                TextField("Enter Reminder", text: $name)
            }

            Section(header: Text("Time")) {
                DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
            }

            Section(header: Text("Repeat")) {
                WeekdayPicker(selection: $repeatDays)
            }

            Section(header: Text("Type")) {
                Picker(selection: $reminderType, label: Text("Reminder Type")) {
                    ForEach(ReminderType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var name = "Apple Academy"
    @Previewable @State var start = Date()
    @Previewable @State var end = Date()
    @Previewable @State var days: Set<Weekday> = .weekdays
    @Previewable @State var type: ReminderType = .clockin

    return ReminderForm(
        name: $name,
        startTime: $start,
        endTime: $end,
        repeatDays: $days,
        reminderType: $type
    )
}
