//
//  SwiftUIView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 20/07/26.
//

import SwiftUI
import SwiftData
import AppIntents


struct AddReminder: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var newType: ReminderType = .both
    @State private var newName: String = ""
    @State private var newClockInWindow = ClockWindow.defaultClockIn
    @State private var newClockOutWindow = ClockWindow.defaultClockOut
    @State private var newInterval: ReminderInterval = .fifteen
    @State private var newRepeatDays: Set<Weekday> = .weekdays

    /// Set once the reminder is saved, which hands the user its generated shortcut.
    @State private var createdReminder: ReminderData?

    private var canSave: Bool {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !newRepeatDays.isEmpty else { return false }
        if newType.covers(.clockIn) && !newClockInWindow.isValid { return false }
        if newType.covers(.clockOut) && !newClockOutWindow.isValid { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            ReminderForm(
                reminderType: $newType,
                name: $newName,
                clockInWindow: $newClockInWindow,
                clockOutWindow: $newClockOutWindow,
                interval: $newInterval,
                repeatDays: $newRepeatDays
            )
            .navigationTitle("New Tap Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addReminder() }
                        .disabled(!canSave)
                }
            }
            .sheet(item: $createdReminder) { reminder in
                ShortcutSetupSheet(reminder: reminder) { dismiss() }
            }
        }
    }

    private func addReminder() {
        let reminder = ReminderData(
            id: UUID(),
            name: newName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: newType,
            clockInWindow: newClockInWindow,
            clockOutWindow: newClockOutWindow,
            intervalMinutes: newInterval.rawValue,
            repeatDays: newRepeatDays
        )

        context.insert(reminder)
        try? context.save()

        // Let Shortcuts and Siri see the new reminder as a pickable parameter.
        TappyShortcuts.updateAppShortcutParameters()
        Task { await NotificationScheduler.refresh() }

        createdReminder = reminder
    }
}

extension ClockWindow {
    /// Sensible starting points so the pickers aren't both sitting on "now".
    static var defaultClockIn: ClockWindow { at(hour: 9, through: 9, minute: 30) }
    static var defaultClockOut: ClockWindow { at(hour: 17, through: 18, minute: 0) }

    private static func at(hour: Int, through endHour: Int, minute: Int) -> ClockWindow {
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        let end = calendar.date(bySettingHour: endHour, minute: minute, second: 0, of: Date()) ?? Date()
        return ClockWindow(start: start, end: end)
    }
}

#Preview {
    AddReminder()
        .modelContainer(for: ReminderData.self, inMemory: true)
}
