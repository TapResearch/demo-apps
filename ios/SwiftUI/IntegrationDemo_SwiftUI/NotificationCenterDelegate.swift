//
//  NotificationCenterDelegate.swift
//  TestApp_SwiftUI
//
//  Created by Jeroen Verbeek on 9/2/25.
//

import Foundation
import TapResearchSDK
import UserNotifications

class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void)
	{
		defer { completionHandler() }

		let handled: Bool = TapResearch.handleNotification(didReceive: response, contentDelegate: TapResearchContentDelegates())
		if handled {
			//
		}
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
	{
		if !TapResearch.handleNotificationPresentation(notification, withCompletionHandler: completionHandler) {
			// handle this for your own notifications
			if #available(iOS 14.0, *) {
				completionHandler([.sound, .banner, .list])
			} else {
				completionHandler([.sound, .alert])
			}
		}
	}

}
