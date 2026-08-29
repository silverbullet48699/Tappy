//
//  ReminderEntity.swift
//  Tappy
//
//  Exposes each saved reminder to the Shortcuts app so the user can pick
//  "which reminder" when they wire the shortcut up to an NFC tag.
//

import AppIntents
import Foundation

struct ReminderEntity: AppEntity, Identifiable {

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Tap Reminder"
    static var defaultQuery = ReminderEntityQuery()

    var id: UUID
    @Property(title: "Name") var name: String
    @Property(title: "Schedule") var scheduleSummary: String
    @Property(title: "Windows") var windowSummary: String
    var reminderType: ReminderType

    init(id: UUID, name: String, scheduleSummary: String, windowSummary: String, reminderType: ReminderType) {
        // Plain stored properties first: assigning through the @Property wrappers
        // touches `self`, so everything else must already be initialized.
        self.id = id
        self.reminderType = reminderType
        self.name = name
        self.scheduleSummary = scheduleSummary
        self.windowSummary = windowSummary
    }

    init(reminder: ReminderData) {
        self.init(
            id: reminder.id,
            name: reminder.ReminderName,
            scheduleSummary: reminder.scheduleSummary,
            windowSummary: reminder.windowSummary,
            reminderType: reminder.reminderType
        )
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(scheduleSummary) · \(windowSummary)",
            image: .init(systemName: "wave.3.right.circle.fill")
        )
    }
}

struct ReminderEntityQuery: EntityQuery {

    @MainActor
    func entities(for identifiers: [ReminderEntity.ID]) async throws -> [ReminderEntity] {
        try TappyDataManager.allReminders()
            .filter { identifiers.contains($0.id) }
            .map(ReminderEntity.init(reminder:))
    }

    @MainActor
    func suggestedEntities() async throws -> [ReminderEntity] {
        try TappyDataManager.allReminders().map(ReminderEntity.init(reminder:))
    }

    @MainActor
    func defaultResult() async -> ReminderEntity? {
        try? await suggestedEntities().first
    }
}
