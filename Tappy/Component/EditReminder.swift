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

    @State private var newName: String
    @State private var newStartTime: Date
    @State private var newEndTime: Date
    @State private var newRepeatDays: Set<Weekday>
    @State private var selectedReminderType: ReminderType

    @State private var showingShortcutSetup = false

    init(reminder: ReminderData) {
        self.reminder = reminder
        _newName = State(initialValue: reminder.ReminderName)
        _newStartTime = State(initialValue: reminder.startTime)
        _newEndTime = State(initialValue: reminder.endTime)
        _newRepeatDays = State(initialValue: reminder.repeatDays)
        _selectedReminderType = State(initialValue: reminder.reminderType)
    }

    private var canSave: Bool {
        !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !newRepeatDays.isEmpty
    }

    var body: some View {
        NavigationStack {
            ReminderForm(
                name: $newName,
                startTime: $newStartTime,
                endTime: $newEndTime,
                repeatDays: $newRepeatDays,
                reminderType: $selectedReminderType
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
        reminder.ReminderName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        reminder.startTime = newStartTime
        reminder.endTime = newEndTime
        reminder.repeatDays = newRepeatDays
        reminder.reminderType = selectedReminderType
        reminder.intervalTime = newEndTime.timeIntervalSince(newStartTime)

        try? context.save()

        // The reminder's name or type may have changed, so refresh what Shortcuts shows.
        TappyShortcuts.updateAppShortcutParameters()

        dismiss()
    }
}

#Preview {
    EditReminder(reminder: ReminderData(
        name: "Preview Reminder",
        intervalTime: 0,
        startTime: .now,
        endTime: .now,
        repeatDays: .weekdays,
        typeReminder: ReminderType.clockin.rawValue
    ))
    .modelContainer(for: ReminderData.self, inMemory: true)
}
