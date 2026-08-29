//
//  NotificationPresenter.swift
//  Tappy
//
//  Without a delegate saying otherwise, iOS suppresses notifications while the
//  app is in the foreground — which would make the nudges look broken exactly
//  when someone is testing them.
//

import Foundation
import UserNotifications

final class NotificationPresenter: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationPresenter()

    func register() {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
