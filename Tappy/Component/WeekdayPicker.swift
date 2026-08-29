//
//  WeekdayPicker.swift
//  Tappy
//
//  Monday–Saturday day chips. Replaces the single Date the form used to store,
//  since a clock in/out reminder repeats weekly rather than happening once.
//

import SwiftUI

struct WeekdayPicker: View {

    @Binding var selection: Set<Weekday>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ForEach(Weekday.allCases) { day in
                    Button {
                        toggle(day)
                    } label: {
                        Text(day.shortLabel)
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                Circle()
                                    .fill(selection.contains(day) ? Color.accentColor : Color(.secondarySystemBackground))
                                    .frame(width: 40, height: 40)
                            )
                            .foregroundStyle(selection.contains(day) ? Color.white : Color.primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(day.fullName)
                    .accessibilityAddTraits(selection.contains(day) ? .isSelected : [])
                }
            }

            HStack {
                Text(selection.summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Weekdays") { selection = .weekdays }
                    .font(.footnote)
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 4)
    }

    private func toggle(_ day: Weekday) {
        if selection.contains(day) {
            selection.remove(day)
        } else {
            selection.insert(day)
        }
    }
}

#Preview {
    @Previewable @State var days: Set<Weekday> = .weekdays
    return Form {
        Section("Repeat") {
            WeekdayPicker(selection: $days)
        }
    }
}
