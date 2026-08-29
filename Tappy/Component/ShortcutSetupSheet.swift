//
//  ShortcutSetupSheet.swift
//  Tappy
//
//  Shown right after a reminder is saved. The reminder now exists as a parameter
//  of Tappy's "Log Clock" action, so this hands the user that shortcut and walks
//  them through attaching it to an NFC tag themselves.
//

import SwiftUI
import AppIntents

struct ShortcutSetupSheet: View {

    let reminder: ReminderData
    /// Called when the user is done, so the presenting sheet can close too.
    var onFinish: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var intent: LogClockIntent {
        let intent = LogClockIntent()
        intent.reminder = ReminderEntity(reminder: reminder)
        intent.action = reminder.reminderType
        return intent
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "wave.3.right.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.accentColor)

                        Text("Shortcut ready")
                            .font(.title2.bold())

                        Text("“\(reminder.ReminderName)” is now available in the Shortcuts app as a **Log Clock** action. Attach it to your card and every tap gets documented.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    summaryCard

                    SiriTipView(intent: intent)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attach it to your card")
                            .font(.headline)

                        instruction(1, "Open Shortcuts, go to **Automation**, and tap **+**.")
                        instruction(2, "Choose **NFC**, then **Scan** and hold your card to the top of your iPhone.")
                        instruction(3, "Add the **Log Clock** action from Tappy.")
                        instruction(4, "Pick **\(reminder.ReminderName)** as the reminder, then turn off *Ask Before Running*.")
                    }

                    VStack(spacing: 12) {
                        Button {
                            openShortcutsApp()
                        } label: {
                            Label("Open Shortcuts", systemImage: "arrow.up.forward.app")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        ShortcutsLink()
                            .shortcutsLinkStyle(.automatic)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                        onFinish()
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(reminder.ReminderName)
                .font(.headline)
            Text(reminder.scheduleSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(reminder.startTime.formatted(date: .omitted, time: .shortened)) – \(reminder.endTime.formatted(date: .omitted, time: .shortened))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func instruction(_ number: Int, _ text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.accentColor))
            Text(text)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func openShortcutsApp() {
        guard let url = URL(string: "shortcuts://") else { return }
        openURL(url)
    }
}

#Preview {
    ShortcutSetupSheet(reminder: ReminderData(
        name: "Apple Academy",
        intervalTime: 0,
        startTime: .now,
        endTime: .now,
        repeatDays: .weekdays,
        typeReminder: ReminderType.clockin.rawValue
    ))
}
