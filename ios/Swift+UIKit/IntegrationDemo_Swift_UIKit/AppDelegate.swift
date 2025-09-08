//
//  AppDelegate.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import UIKit
import TapResearchSDK
import UserNotifications

protocol LogPrint {
	func logPrint(_ text: String, _ typeName: String, _ funcName: String)
}

extension LogPrint {

	func logPrint(_ text: String = "", _ typeName: String = "\(Self.self)", _ funcName: String = #function)
	{
		print("[\(Date())][\(typeName).\(funcName)] \(text)")
	}

}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.delegate = self
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void
	) {
		defer { completionHandler() }

		let handled: Bool = TapResearch.handleNotification(didReceive: response, contentDelegate: self)
		if handled {
			// Handle other non-TapResearch notifications
		}
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

		if !TapResearch.handleNotificationPresentation(notification, withCompletionHandler: completionHandler) {
			// handle this for your own notifications
			if #available(iOS 14.0, *) {
				completionHandler([.sound, .banner, .list])
			} else {
				completionHandler([.sound, .alert])
			}
		}
	}

	func onTapResearchContentShown(forPlacement placement: String) {
		// perhaps use a notification to let the current view controller know about this event (these are about as instantaneous as a function call)
	}

	func onTapResearchContentDismissed(forPlacement placement: String) {
		// perhaps use a notification to let the current view controller know about this event (these are about as instantaneous as a function call)
	}

}
