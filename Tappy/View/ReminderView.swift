//
//  ReminderView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//

import SwiftUI
import SwiftData
import AppIntents
import UserNotifications


struct ReminderView: View {
    @Query(sort: \ReminderData.ReminderName) private var reminderData: [ReminderData]
    @Environment(\.modelContext) private var context

    @State private var showingAddReminder = false
    @State private var selectedReminder: ReminderData?
    @State private var notificationsAllowed = true
    @State private var droppedNudges = 0

    var body: some View {
        NavigationStack {
            Group {
                if !notificationsAllowed {
                    notificationWarning
                }
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
            .task { await refreshNotificationState() }
        }
    }

    /// Reminders are useless if the nudges can't be delivered, so say so plainly
    /// rather than letting them silently never arrive.
    private var notificationWarning: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Notifications are off", systemImage: "bell.slash.fill")
                .font(.subheadline.bold())
            Text("Tappy can still record taps, but it can't remind you. Turn notifications on in Settings.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Open Settings", destination: url)
                    .font(.caption.bold())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func refreshNotificationState() async {
        notificationsAllowed = await NotificationScheduler.isAuthorized
        droppedNudges = max(0, NotificationScheduler.lastRequestedCount - NotificationScheduler.lastScheduledCount)
    }

    private func reminderRow(_ reminder: ReminderData) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(reminder.ReminderName)
                .font(.headline)

            Text("\(reminder.scheduleSummary) · \(reminder.intervalSummary)")
                .font(.caption)
                .foregroundStyle(.secondary)

            // One line per window, so a "both" reminder reads at a glance.
            ForEach(reminder.activeWindows, id: \.clockType) { entry in
                Label(entry.window.summary, systemImage: entry.clockType.symbolName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func deleteReminder(_ reminder: ReminderData) {
        context.delete(reminder)
        try? context.save()
        TappyShortcuts.updateAppShortcutParameters()
        Task { await NotificationScheduler.refresh() }
    }
}


#Preview {
    ReminderView()
        .modelContainer(for: ReminderData.self, inMemory: true)
}
