//
//  CalendarViewModel.swift
//  Tappy
//
//  Backs the calendar with real data: which reminders were due on a given day,
//  and which taps actually got recorded against them.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class CalendarViewModel {

    // MARK: - Output

    private(set) var selectedDate: Date
    /// Reminders whose repeat days include the selected date.
    private(set) var scheduledReminders: [ReminderData] = []
    /// Every tap recorded on the selected date, earliest first.
    private(set) var entries: [ClockEntry] = []
    /// Days in the visible month that have at least one recorded tap.
    private(set) var recordedDaysThisMonth: Set<Date> = []

    private var context: ModelContext?
    private let calendar: Calendar

    init(date: Date = .now, calendar: Calendar = .current) {
        self.selectedDate = date
        self.calendar = calendar
    }

    /// Hand in the view's context so previews and the app share the same path.
    func configure(context: ModelContext) {
        self.context = context
        reload()
    }

    func select(_ date: Date) {
        selectedDate = date
        reload()
    }

    // MARK: - Derived state

    /// One row per reminder due on the selected day, with whatever was recorded.
    var dayStatuses: [ReminderDayStatus] {
        scheduledReminders.map { reminder in
            let mine = entries.filter { $0.reminderID == reminder.id }
            return ReminderDayStatus(
                reminder: reminder,
                // First tap in, last tap out — the readings that bound the day.
                clockIn: mine.first { $0.clockType == .clockIn },
                clockOut: mine.last { $0.clockType == .clockOut }
            )
        }
    }

    var isToday: Bool { calendar.isDateInToday(selectedDate) }

    var hasAnythingToShow: Bool { !scheduledReminders.isEmpty || !entries.isEmpty }

    /// Taps recorded on a day when no reminder was scheduled — an unplanned shift,
    /// or a reminder that has since been edited or deleted.
    var unscheduledEntries: [ClockEntry] {
        let scheduledIDs = Set(scheduledReminders.map(\.id))
        return entries.filter { !scheduledIDs.contains($0.reminderID) }
    }

    var daySummary: String {
        if scheduledReminders.isEmpty && entries.isEmpty { return "Nothing scheduled" }
        let done = dayStatuses.filter(\.isComplete).count
        let total = scheduledReminders.count
        if total == 0 { return "\(entries.count) tap\(entries.count == 1 ? "" : "s") recorded" }
        return "\(done) of \(total) reminder\(total == 1 ? "" : "s") complete"
    }

    // MARK: - Fetching

    func reload() {
        guard let context else { return }
        let (start, end) = dayBounds(for: selectedDate)

        do {
            let entryDescriptor = FetchDescriptor<ClockEntry>(
                predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end },
                sortBy: [SortDescriptor(\.timestamp, order: .forward)]
            )
            entries = try context.fetch(entryDescriptor)

            // `repeatDayNumbers` is a stored array, which doesn't translate into a
            // SwiftData predicate — the list is small, so filter it in memory.
            let all = try context.fetch(FetchDescriptor<ReminderData>(
                sortBy: [SortDescriptor(\.ReminderName)]
            ))
            scheduledReminders = all.filter { $0.repeats(on: selectedDate, calendar: calendar) }

            recordedDaysThisMonth = try fetchRecordedDays(in: selectedDate)
        } catch {
            print("[Tappy] Calendar fetch failed: \(error)")
            entries = []
            scheduledReminders = []
            recordedDaysThisMonth = []
        }
    }

    private func fetchRecordedDays(in month: Date) throws -> Set<Date> {
        guard let context,
              let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let start = interval.start
        let end = interval.end
        let descriptor = FetchDescriptor<ClockEntry>(
            predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end }
        )
        return Set(try context.fetch(descriptor).map { calendar.startOfDay(for: $0.timestamp) })
    }

    private func dayBounds(for date: Date) -> (Date, Date) {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return (start, end)
    }
}

/// What one reminder's day looked like: what was due, and what was actually tapped.
struct ReminderDayStatus: Identifiable {

    let reminder: ReminderData
    let clockIn: ClockEntry?
    let clockOut: ClockEntry?

    var id: UUID { reminder.id }

    var expected: [ClockType] { reminder.reminderType.clockTypes }

    func entry(for clockType: ClockType) -> ClockEntry? {
        clockType == .clockIn ? clockIn : clockOut
    }

    var recordedCount: Int {
        expected.filter { entry(for: $0) != nil }.count
    }

    var isComplete: Bool { recordedCount == expected.count }

    /// "Complete", "Clock Out missing", "Nothing recorded"
    var statusText: String {
        if isComplete { return "Complete" }
        if recordedCount == 0 { return "Nothing recorded" }
        let missing = expected.filter { entry(for: $0) == nil }.map(\.displayName)
        return "\(missing.joined(separator: " and ")) missing"
    }

    /// How long the day ran, when both ends were recorded.
    var workedDuration: TimeInterval? {
        guard let clockIn, let clockOut else { return nil }
        let span = clockOut.timestamp.timeIntervalSince(clockIn.timestamp)
        return span > 0 ? span : nil
    }

    var workedSummary: String? {
        guard let workedDuration else { return nil }
        let hours = Int(workedDuration) / 3600
        let minutes = (Int(workedDuration) % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}
