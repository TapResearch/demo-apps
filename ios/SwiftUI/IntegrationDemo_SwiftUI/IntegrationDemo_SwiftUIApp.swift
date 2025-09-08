//
//  swiftui_example_tapresearchApp.swift
//  swiftui-example-tapresearch
//
//  Created by Michael Quinn on 5/20/23.
//

import SwiftUI
import UserNotifications

@main struct swiftui_example_tapresearchApp: App {

	let notificationDelegate = NotificationCenterDelegate()

	init() {
		UNUserNotificationCenter.current().delegate = notificationDelegate
	}

	var body: some Scene {
		WindowGroup {
			MainContent()
		}
	}

}
