//
//  ReminderDetailSheet.swift
//  Tappy
//
//  Created by Muhammad Rasya Devansyah on 18/07/26.
//

import SwiftUI
import SwiftData

struct ReminderDetailSheet: View {

    let date: Date

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CalendarViewModel

    init(date: Date) {
        self.date = date
        _viewModel = State(initialValue: CalendarViewModel(date: date))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.dayStatuses.isEmpty && viewModel.entries.isEmpty {
                        ContentUnavailableView(
                            "Nothing on this day",
                            systemImage: "calendar.badge.minus",
                            description: Text("No reminder repeats on this weekday, and nothing was tapped.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(viewModel.dayStatuses) { status in
                            reminderBlock(status)
                        }
                        historySection
                    }
                }
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .labelStyle(.iconOnly)
                }
            }
        }
        .presentationDetents([.large])
        .task { viewModel.configure(context: context) }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            viewModel.reload()
        }
    }

    private func reminderBlock(_ status: ReminderDayStatus) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(status.reminder.ReminderName)
                    .font(.headline)
                Spacer()
                Label(status.statusText, systemImage: status.isComplete ? "checkmark.circle.fill" : "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(status.isComplete ? .green : .orange)
            }

            // Only the taps this reminder actually expects get a card.
            ForEach(status.expected, id: \.self) { clockType in
                ClockCard(clockType: clockType, date: status.entry(for: clockType)?.timestamp)
            }

            if let worked = status.workedSummary {
                Text("Total \(worked)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var historySection: some View {
        VStack(spacing: 16) {
            Text("History")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.entries.isEmpty {
                Text("No taps recorded on this day.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(viewModel.entries) { entry in
                    ClockHistory(
                        date: entry.timestamp,
                        clockType: entry.clockType,
                        reminderName: entry.reminderName
                    )
                }
            }
        }
    }
}

#Preview {
    ReminderDetailSheet(date: Date.now)
        .modelContainer(for: [ReminderData.self, ClockEntry.self], inMemory: true)
}
