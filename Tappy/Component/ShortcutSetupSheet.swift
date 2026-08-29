//
//  ShortcutSetupSheet.swift
//  Tappy
//
//  Shown right after a reminder is saved. The reminder now exists as a parameter
//  of Tappy's clock actions, so this hands the user that shortcut and walks
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

    /// A "both" reminder can't tell the two taps apart from the card alone, so its
    /// shortcut asks in the Dynamic Island. Single-action reminders log directly.
    private var usesPrompt: Bool { reminder.reminderType == .both }

    private var promptIntent: StartClockPromptIntent {
        let intent = StartClockPromptIntent()
        intent.reminder = ReminderEntity(reminder: reminder)
        return intent
    }

    private var logIntent: LogClockIntent {
        let intent = LogClockIntent()
        intent.reminder = ReminderEntity(reminder: reminder)
        intent.action = reminder.resolvedClockType()
        return intent
    }

    private var actionName: String {
        usesPrompt ? "Ask Clock In or Clock Out" : "Log Clock In or Out"
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

                        Text(usesPrompt
                             ? "“\(reminder.ReminderName)” is now in the Shortcuts app as an **\(actionName)** action. Tap your card and Tappy asks — in the Dynamic Island — which one it was."
                             : "“\(reminder.ReminderName)” is now in the Shortcuts app as a **\(actionName)** action. Attach it to your card and every tap gets documented.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    summaryCard

                    if usesPrompt {
                        SiriTipView(intent: promptIntent)
                    } else {
                        SiriTipView(intent: logIntent)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attach it to your card")
                            .font(.headline)

                        instruction(1, "Open Shortcuts, go to **Automation**, and tap **+**.")
                        instruction(2, "Choose **NFC**, then **Scan** and hold your card to the top of your iPhone.")
                        instruction(3, "Add the **\(actionName)** action from Tappy.")
                        instruction(4, "Pick **\(reminder.ReminderName)** as the reminder, then turn off *Ask Before Running*.")

                        if usesPrompt {
                            Text("Your building uses the same card on both readers, so Tappy can't tell the taps apart on its own. After each tap it raises a Dynamic Island prompt with **Clock In** and **Clock Out** — the likelier one for the time of day is highlighted, and either is a single tap.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 34)
                        }
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
        VStack(alignment: .leading, spacing: 8) {
            Text(reminder.ReminderName)
                .font(.headline)
            Text("\(reminder.scheduleSummary) · \(reminder.intervalSummary)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(reminder.activeWindows, id: \.clockType) { entry in
                Label("\(entry.clockType.displayName)  \(entry.window.summary)", systemImage: entry.clockType.symbolName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
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
        type: .both,
        clockInWindow: .defaultClockIn,
        clockOutWindow: .defaultClockOut,
        intervalMinutes: 15,
        repeatDays: .weekdays
    ))
}
