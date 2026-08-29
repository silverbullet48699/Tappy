//
//  ClockPromptLiveActivity.swift
//  TappyWidget
//
//  The Dynamic Island prompt. One card opens both readers in the building, so
//  after a tap Tappy asks which one it was instead of guessing.
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct ClockPromptLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ClockPromptAttributes.self) { context in
            LockScreenPrompt(context: context)
                .activityBackgroundTint(Color.black.opacity(0.55))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.teal)
                        .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if let resolved = context.state.resolved {
                        Label(resolved.displayName, systemImage: "checkmark.circle.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                            .padding(.trailing, 4)
                    } else {
                        Text(context.attributes.reminderName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .padding(.trailing, 4)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.isAwaitingChoice ? "Which tap was that?" : "Recorded")
                        .font(.headline)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isAwaitingChoice {
                        ChoiceButtons(context: context)
                    } else {
                        ResolvedFooter(context: context)
                    }
                }
            } compactLeading: {
                Image(systemName: "wave.3.right.circle.fill")
                    .foregroundStyle(.teal)
            } compactTrailing: {
                if let resolved = context.state.resolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    // A question mark is the honest state: Tappy doesn't know yet.
                    Text("?")
                        .font(.caption.bold())
                        .foregroundStyle(.teal)
                }
            } minimal: {
                Image(systemName: context.state.isAwaitingChoice ? "questionmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(context.state.isAwaitingChoice ? .teal : .green)
            }
            .keylineTint(.teal)
        }
    }
}

// MARK: - Pieces

/// The two buttons. Both run `ResolveClockIntent`, which the system performs in
/// the app's process so it can write to the shared store.
private struct ChoiceButtons: View {
    let context: ActivityViewContext<ClockPromptAttributes>

    var body: some View {
        HStack(spacing: 10) {
            ForEach(ClockType.allCases) { clockType in
                Button(intent: ResolveClockIntent(
                    reminderID: context.attributes.reminderID,
                    activityID: context.activityID,
                    clockType: clockType
                )) {
                    VStack(spacing: 2) {
                        Label(clockType.displayName, systemImage: clockType.symbolName)
                            .font(.subheadline.bold())
                        Text(context.attributes.windowSummary(for: clockType))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        // Tappy's time-of-day guess is highlighted, so the usual
                        // case is one tap — but either button is one tap.
                        .fill(clockType == context.state.suggested ? Color.teal.opacity(0.35) : Color.white.opacity(0.12))
                )
            }
        }
        .padding(.horizontal, 4)
    }
}

private struct ResolvedFooter: View {
    let context: ActivityViewContext<ClockPromptAttributes>

    var body: some View {
        if let resolved = context.state.resolved, let at = context.state.loggedAt {
            Label(
                "\(resolved.displayName) recorded at \(at.formatted(date: .omitted, time: .shortened))",
                systemImage: resolved.symbolName
            )
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }
}

/// Lock screen and banner presentation — same question, more room.
private struct LockScreenPrompt: View {
    let context: ActivityViewContext<ClockPromptAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(context.attributes.reminderName, systemImage: "wave.3.right.circle.fill")
                    .font(.headline)
                Spacer()
                if context.state.resolved != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            if context.state.isAwaitingChoice {
                Text("Which tap was that?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ChoiceButtons(context: context)
            } else {
                ResolvedFooter(context: context)
            }
        }
        .padding()
    }
}
