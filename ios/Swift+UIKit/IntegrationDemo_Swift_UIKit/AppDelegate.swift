//
//  AppDelegate.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import UIKit
import TapResearchSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate, TapResearchSDKDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.	
		initTapResearch()
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

	//MARK: - Init TapResearchSDK

	let apiToken: String = "0b5dcbae8151c1b82d69697dce004bf2"
	let userIdentifier: String = "public-demo-test-user"

	func initTapResearch() {

		TapResearchSDK.initialize(withAPIToken: apiToken, userIdentifier: userIdentifier, sdkDelegate: self) { (error: TRError?) in
			if let error = error {
				print(error.localizedDescription as Any)
			}
		}
	}

	//MARK: - TapResearchSDKDelegate

	///---------------------------------------------------------------------------------------------
	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("onTapResearchDidReceiveRewards(rewards...)")
	}

	///---------------------------------------------------------------------------------------------
	func onTapResearchDidError(_ error: TRError) {
		print("onTapResearchDidError: \(error.userInfo[TRError.TapResearchErrorCodeString] ?? "(No code)") \(error.localizedDescription)")
	}

}
