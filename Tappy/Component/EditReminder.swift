//
//  Edit Reminder.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 22/07/26.
//

import SwiftUI
import SwiftData
import AppIntents

struct EditReminder: View {

    let reminder: ReminderData
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var newType: ReminderType
    @State private var newName: String
    @State private var newClockInWindow: ClockWindow
    @State private var newClockOutWindow: ClockWindow
    @State private var newInterval: ReminderInterval
    @State private var newRepeatDays: Set<Weekday>

    @State private var showingShortcutSetup = false

    init(reminder: ReminderData) {
        self.reminder = reminder
        _newType = State(initialValue: reminder.reminderType)
        _newName = State(initialValue: reminder.ReminderName)
        _newClockInWindow = State(initialValue: reminder.clockInWindow)
        _newClockOutWindow = State(initialValue: reminder.clockOutWindow)
        _newInterval = State(initialValue: reminder.interval)
        _newRepeatDays = State(initialValue: reminder.repeatDays)
    }

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
            .navigationTitle("Edit Tap Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveReminder() }
                        .disabled(!canSave)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingShortcutSetup = true
                    } label: {
                        Label("Shortcut Setup", systemImage: "wave.3.right.circle")
                    }
                }
            }
            .sheet(isPresented: $showingShortcutSetup) {
                ShortcutSetupSheet(reminder: reminder)
            }
        }
    }

    private func saveReminder() {
        reminder.reminderType = newType
        reminder.ReminderName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        reminder.clockInWindow = newClockInWindow
        reminder.clockOutWindow = newClockOutWindow
        reminder.interval = newInterval
        reminder.repeatDays = newRepeatDays

        try? context.save()

        // The reminder's name or type may have changed, so refresh what Shortcuts shows.
        TappyShortcuts.updateAppShortcutParameters()
        Task { await NotificationScheduler.refresh() }

        dismiss()
    }
}

#Preview {
    EditReminder(reminder: ReminderData(
        name: "Preview Reminder",
        type: .both,
        clockInWindow: .defaultClockIn,
        clockOutWindow: .defaultClockOut,
        intervalMinutes: 15,
        repeatDays: .weekdays
    ))
    .modelContainer(for: ReminderData.self, inMemory: true)
}
