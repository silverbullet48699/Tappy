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
    /// Reminder ids marked off for the selected day.
    private(set) var absentReminderIDs: Set<UUID> = []

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
                clockOut: mine.last { $0.clockType == .clockOut },
                isAbsent: absentReminderIDs.contains(reminder.id)
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
        if scheduledReminders.isEmpty { return "\(entries.count) tap\(entries.count == 1 ? "" : "s") recorded" }

        // Days off don't count against you, so they leave the denominator.
        let expected = dayStatuses.filter { !$0.isAbsent }
        let daysOff = dayStatuses.count - expected.count
        if expected.isEmpty { return daysOff == 1 ? "Day off" : "Day off (\(daysOff) reminders)" }

        let done = expected.filter(\.isComplete).count
        var text = "\(done) of \(expected.count) reminder\(expected.count == 1 ? "" : "s") complete"
        if daysOff > 0 { text += " · \(daysOff) off" }
        return text
    }

    // MARK: - Absences

    func isAbsent(_ reminder: ReminderData) -> Bool {
        absentReminderIDs.contains(reminder.id)
    }

    /// Marks the selected day off (or back on) for one reminder, then reschedules
    /// so the nudges disappear immediately.
    ///
    /// Goes through the injected context rather than the shared container, so a
    /// preview or test never writes into the real store.
    func setAbsent(_ absent: Bool, for reminder: ReminderData) {
        guard let context else { return }
        let dayStart = calendar.startOfDay(for: selectedDate)
        let reminderID = reminder.id

        do {
            let descriptor = FetchDescriptor<ReminderAbsence>(
                predicate: #Predicate { $0.reminderID == reminderID && $0.dayStart == dayStart }
            )
            let existing = try context.fetch(descriptor).first

            if absent {
                guard existing == nil else { return }
                context.insert(ReminderAbsence(reminderID: reminderID, dayStart: dayStart))
            } else {
                guard let existing else { return }
                context.delete(existing)
            }
            try context.save()

            reload()
            Task { await NotificationScheduler.refresh() }
        } catch {
            print("[Tappy] Could not update absence: \(error)")
        }
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

            let absenceDescriptor = FetchDescriptor<ReminderAbsence>(
                predicate: #Predicate { $0.dayStart >= start && $0.dayStart < end }
            )
            absentReminderIDs = Set(try context.fetch(absenceDescriptor).map(\.reminderID))

            recordedDaysThisMonth = try fetchRecordedDays(in: selectedDate)
        } catch {
            print("[Tappy] Calendar fetch failed: \(error)")
            entries = []
            scheduledReminders = []
            absentReminderIDs = []
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
    /// The user said they aren't going in that day.
    let isAbsent: Bool

    var id: UUID { reminder.id }

    var expected: [ClockType] { reminder.reminderType.clockTypes }

    func entry(for clockType: ClockType) -> ClockEntry? {
        clockType == .clockIn ? clockIn : clockOut
    }

    var recordedCount: Int {
        expected.filter { entry(for: $0) != nil }.count
    }

    /// A day off is never "incomplete" — there was nothing to do.
    var isComplete: Bool { isAbsent || recordedCount == expected.count }

    /// "Day off", "Complete", "Clock Out missing", "Nothing recorded"
    var statusText: String {
        if isAbsent { return "Day off" }
        if recordedCount == expected.count { return "Complete" }
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
