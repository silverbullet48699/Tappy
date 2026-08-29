//
//  CalenderIView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//

import SwiftUI
import SwiftData

struct CalenderIView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = CalendarViewModel()
    @State private var showDetail = false

    private var dateSelection: Binding<Date> {
        Binding(
            get: { viewModel.selectedDate },
            set: { viewModel.select($0) }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    DatePicker(
                        "Select a date",
                        selection: dateSelection,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)

                    monthFooter

                    Divider()

                    daySection
                }
                .padding(.horizontal)
            }
            .navigationTitle("Reminder History")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDetail, onDismiss: viewModel.reload) {
                ReminderDetailSheet(date: viewModel.selectedDate)
            }
        }
        .task { viewModel.configure(context: context) }
        // A tap logged from the Dynamic Island lands in the store while this view
        // is open, so refresh whenever anything saves.
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            viewModel.reload()
        }
    }

    private var monthFooter: some View {
        let days = viewModel.recordedDaysThisMonth.count
        return Text(days == 0 ? "No taps recorded this month" : "\(days) day\(days == 1 ? "" : "s") recorded this month")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var daySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.headline)
                    Text(viewModel.daySummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if viewModel.hasAnythingToShow {
                    Button("Details") { showDetail = true }
                        .buttonStyle(.bordered)
                }
            }

            if viewModel.dayStatuses.isEmpty && viewModel.entries.isEmpty {
                ContentUnavailableView(
                    "Nothing on this day",
                    systemImage: "calendar.badge.minus",
                    description: Text("No reminder repeats on this weekday, and nothing was tapped.")
                )
                .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.dayStatuses) { status in
                    DayStatusCard(status: status) { absent in
                        viewModel.setAbsent(absent, for: status.reminder)
                    }
                }

                if !viewModel.unscheduledEntries.isEmpty {
                    Text("Also recorded")
                        .font(.subheadline.bold())
                        .padding(.top, 4)
                    ForEach(viewModel.unscheduledEntries) { entry in
                        ClockHistory(
                            date: entry.timestamp,
                            clockType: entry.clockType,
                            reminderName: entry.reminderName
                        )
                    }
                }
            }
        }
        .padding(.bottom, 24)
    }
}

/// One reminder's day at a glance: what was due, and what actually got tapped.
struct DayStatusCard: View {
    let status: ReminderDayStatus
    var onAbsenceChange: (Bool) -> Void

    private var statusColor: Color {
        if status.isAbsent { return .secondary }
        return status.isComplete ? .green : .orange
    }

    private var statusIcon: String {
        if status.isAbsent { return "moon.zzz.fill" }
        return status.isComplete ? "checkmark.circle.fill" : "exclamationmark.circle"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(status.reminder.ReminderName)
                    .font(.headline)
                Spacer()
                Label(status.statusText, systemImage: statusIcon)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            Toggle(isOn: Binding(get: { status.isAbsent }, set: onAbsenceChange)) {
                Text("Absent — no reminders this day")
                    .font(.subheadline)
            }
            .toggleStyle(.switch)
            .controlSize(.mini)

            ForEach(status.expected, id: \.self) { clockType in
                HStack {
                    Label(clockType.displayName, systemImage: clockType.symbolName)
                        .font(.subheadline)
                    Spacer()
                    if let entry = status.entry(for: clockType) {
                        Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.subheadline.bold())
                    } else {
                        Text("—")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let worked = status.workedSummary {
                Text("Total \(worked)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(status.isAbsent ? 0.55 : 1)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    CalenderIView()
        .modelContainer(for: [ReminderData.self, ClockEntry.self], inMemory: true)
}
