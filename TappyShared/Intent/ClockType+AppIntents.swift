//
//  ClockType+AppIntents.swift
//  Tappy
//
//  Lives in the shared folder because the Live Activity's buttons take a
//  ClockType parameter, so the widget extension has to see this conformance too.
//

import AppIntents

extension ClockType: AppEnum {
    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation { "Clock Action" }

    nonisolated static var caseDisplayRepresentations: [ClockType: DisplayRepresentation] { [
        .clockIn: DisplayRepresentation(title: "Clock In", image: .init(systemName: "arrow.right.to.line")),
        .clockOut: DisplayRepresentation(title: "Clock Out", image: .init(systemName: "arrow.left.to.line"))
    ] }
}
