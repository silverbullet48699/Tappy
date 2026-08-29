//
//  ReminderView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//

import SwiftUI
import SwiftData
import AppIntents


struct ReminderView: View {
    @Query(sort: \ReminderData.ReminderName) private var reminderData: [ReminderData]
    @Environment(\.modelContext) private var context

    @State private var showingAddReminder = false
    @State private var selectedReminder: ReminderData?

    var body: some View {
        NavigationStack {
            Group {
                if reminderData.isEmpty {
                    ContentUnavailableView(
                        "Belum ada Reminder",
                        systemImage: "bell.slash",
                        description: Text("Add a reminder and Tappy generates a shortcut you can attach to your card.")
                    )
                } else {
                    List {
                        ForEach(reminderData) { reminder in
                            Button {
                                selectedReminder = reminder
                            } label: {
                                reminderRow(reminder)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteReminder(reminder)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminder")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminder()
            }
            .sheet(item: $selectedReminder) { reminder in
                EditReminder(reminder: reminder)
            }
        }
    }

    private func reminderRow(_ reminder: ReminderData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reminder.ReminderName)
                .font(.headline)
            Text(reminder.scheduleSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(reminder.startTime.formatted(date: .omitted, time: .shortened)) – \(reminder.endTime.formatted(date: .omitted, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func deleteReminder(_ reminder: ReminderData) {
        context.delete(reminder)
        try? context.save()
        TappyShortcuts.updateAppShortcutParameters()
    }
}


#Preview {
    ReminderView()
        .modelContainer(for: ReminderData.self, inMemory: true)
}
