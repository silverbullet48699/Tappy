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

    @State private var newName: String = ""
    @State private var newStartTime: Date = Date()
    @State private var newEndTime: Date = Date()
    @State private var newRepeatDays: Set<Weekday> = .weekdays
    @State private var selectedReminderType: ReminderType = .clockin

    /// Set once the reminder is saved, which hands the user its generated shortcut.
    @State private var createdReminder: ReminderData?

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
            intervalTime: newEndTime.timeIntervalSince(newStartTime),
            startTime: newStartTime,
            endTime: newEndTime,
            repeatDays: newRepeatDays,
            typeReminder: selectedReminderType.rawValue
        )

        context.insert(reminder)
        try? context.save()

        // Let Shortcuts and Siri see the new reminder as a pickable parameter.
        TappyShortcuts.updateAppShortcutParameters()

        createdReminder = reminder
    }
}

#Preview {
    AddReminder()
        .modelContainer(for: ReminderData.self, inMemory: true)
}
