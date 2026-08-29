//
//  ReminderForm.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 23/07/26.
//

import SwiftUI

struct ReminderForm: View {

    @Binding var reminderType: ReminderType
    @Binding var name: String
    @Binding var clockInWindow: ClockWindow
    @Binding var clockOutWindow: ClockWindow
    @Binding var interval: ReminderInterval
    @Binding var repeatDays: Set<Weekday>

    var body: some View {
        Form {
            // Type comes first: it decides how many windows the rest of the form shows.
            Section {
                Picker("Reminder Type", selection: $reminderType) {
                    ForEach(ReminderType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            } header: {
                Text("Reminder Type")
            } footer: {
                Text(typeFooter)
            }

            Section(header: Text("Reminder Name")) {
                TextField("Enter Reminder", text: $name)
            }

            if reminderType.covers(.clockIn) {
                windowSection(for: .clockIn, window: $clockInWindow)
            }

            if reminderType.covers(.clockOut) {
                windowSection(for: .clockOut, window: $clockOutWindow)
            }

            Section {
                Picker("Remind Me", selection: $interval) {
                    ForEach(ReminderInterval.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
            } header: {
                Text("Reminder Interval")
            } footer: {
                Text("Tappy nudges you this often while you're inside a window, until you tap.")
            }

            Section(header: Text("Repeat")) {
                WeekdayPicker(selection: $repeatDays)
            }
        }
        .animation(.default, value: reminderType)
    }

    private func windowSection(for clockType: ClockType, window: Binding<ClockWindow>) -> some View {
        Section {
            DatePicker("Start Time", selection: window.start, displayedComponents: [.hourAndMinute])
            DatePicker("End Time", selection: window.end, displayedComponents: [.hourAndMinute])
        } header: {
            Label("\(clockType.displayName) Window", systemImage: clockType.symbolName)
        } footer: {
            if window.wrappedValue.isValid {
                Text(windowFooter(for: clockType, window: window.wrappedValue))
            } else {
                Text("End Time must be after Start Time.")
                    .foregroundStyle(.red)
            }
        }
    }

    private func windowFooter(for clockType: ClockType, window: ClockWindow) -> String {
        let count = window.reminderTimes(everyMinutes: interval.rawValue).count
        let verb = clockType == .clockIn ? "tap in" : "tap out"
        return "The stretch you should \(verb) during — \(count) reminder\(count == 1 ? "" : "s") at \(interval.displayName) apart."
    }

    private var typeFooter: String {
        switch reminderType {
        case .clockin: return "One window to tap in."
        case .clockout: return "One window to tap out."
        case .both: return "Two windows — one to tap in, one to tap out."
        }
    }
}

#Preview {
    @Previewable @State var type: ReminderType = .both
    @Previewable @State var name = "Apple Academy"
    @Previewable @State var inWindow = ClockWindow(start: .now, end: .now.addingTimeInterval(1800))
    @Previewable @State var outWindow = ClockWindow(start: .now, end: .now.addingTimeInterval(1800))
    @Previewable @State var interval: ReminderInterval = .fifteen
    @Previewable @State var days: Set<Weekday> = .weekdays

    return ReminderForm(
        reminderType: $type,
        name: $name,
        clockInWindow: $inWindow,
        clockOutWindow: $outWindow,
        interval: $interval,
        repeatDays: $days
    )
}
