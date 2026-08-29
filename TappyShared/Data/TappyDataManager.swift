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

    /// Both the app and the widget extension open the store from this group, so a
    /// button tapped in the Dynamic Island writes where the app can read it.
    static let appGroupID = "group.stephanie.Tappy"

    static let schema = Schema([ReminderData.self, ClockEntry.self, ReminderAbsence.self])

    /// Where the shared store lives inside the App Group.
    ///
    /// The group container is handed to us empty — `Library/Application Support`
    /// does not exist until something creates it, and SwiftData will not create it
    /// for us. Pointing at an explicit URL and making the directory first avoids
    /// the "Sandbox access to file-write-create denied" failure.
    static var sharedStoreURL: URL? {
        guard let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return nil
        }
        let directory = base.appending(path: "Library/Application Support", directoryHint: .isDirectory)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            print("[Tappy] Could not prepare the App Group directory: \(error)")
            return nil
        }
        return directory.appending(path: "Tappy.store")
    }

    /// The pre-App-Group location, from before the widget extension existed.
    private static var legacyStoreURL: URL? {
        try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appending(path: "default.store")
    }

    /// Moving the store into the App Group would otherwise strand reminders saved
    /// before this change, so bring them across once.
    private static func migrateLegacyStoreIfNeeded(to destination: URL) {
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: destination.path),
              let legacy = legacyStoreURL,
              fileManager.fileExists(atPath: legacy.path) else { return }

        // SQLite keeps its write-ahead log beside the store; all three travel together.
        for suffix in ["", "-wal", "-shm"] {
            let from = URL(fileURLWithPath: legacy.path + suffix)
            let to = URL(fileURLWithPath: destination.path + suffix)
            guard fileManager.fileExists(atPath: from.path) else { continue }
            do {
                try fileManager.copyItem(at: from, to: to)
            } catch {
                print("[Tappy] Could not migrate \(from.lastPathComponent) into the App Group: \(error)")
            }
        }
        print("[Tappy] Migrated the existing store into the App Group container.")
    }

    static let sharedContainer: ModelContainer = {
        // Preferred: the shared App Group store, which the widget extension can
        // also open.
        if let url = sharedStoreURL {
            migrateLegacyStoreIfNeeded(to: url)
            do {
                return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: url))
            } catch {
                print("[Tappy] App Group store unavailable (\(error)); falling back to the local store.")
            }
        }
        // The App Group isn't provisioned. The app still works; only the Live
        // Activity buttons need the group.
        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema))
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

    /// Clock entries inside a time range, earliest first.
    @MainActor
    static func entries(from start: Date, to end: Date) throws -> [ClockEntry] {
        let descriptor = FetchDescriptor<ClockEntry>(
            predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        return try context().fetch(descriptor)
    }

    // MARK: - Absences

    /// Days marked off inside a range.
    @MainActor
    static func absences(from start: Date, to end: Date) throws -> [ReminderAbsence] {
        let descriptor = FetchDescriptor<ReminderAbsence>(
            predicate: #Predicate { $0.dayStart >= start && $0.dayStart < end }
        )
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
