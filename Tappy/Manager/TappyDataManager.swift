//
//  TappyDataManager.swift
//  Tappy
//
//  One shared SwiftData stack. The app UI and the App Intents that Shortcuts runs
//  both go through here so an NFC tap writes into the same store the app reads.
//

import Foundation
import SwiftData

enum TappyDataManager {

    static let schema = Schema([ReminderData.self, ClockEntry.self])

    static let sharedContainer: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// A fresh context for background work such as an App Intent invocation.
    @MainActor
    static func context() -> ModelContext {
        sharedContainer.mainContext
    }

    /// Look up a reminder by the id Shortcuts hands back to us.
    @MainActor
    static func reminder(with id: UUID) throws -> ReminderData? {
        let descriptor = FetchDescriptor<ReminderData>(predicate: #Predicate { $0.id == id })
        return try context().fetch(descriptor).first
    }

    @MainActor
    static func allReminders() throws -> [ReminderData] {
        let descriptor = FetchDescriptor<ReminderData>(sortBy: [SortDescriptor(\.ReminderName)])
        return try context().fetch(descriptor)
    }

    /// Writes the row that documents a clock in/out.
    @MainActor
    @discardableResult
    static func logClock(for reminder: ReminderData, clockType: ClockType, at date: Date = Date(), source: String = "shortcut") throws -> ClockEntry {
        let entry = ClockEntry(
            reminderID: reminder.id,
            reminderName: reminder.ReminderName,
            clockType: clockType,
            timestamp: date,
            source: source
        )
        let context = context()
        context.insert(entry)
        try context.save()
        return entry
    }
}
