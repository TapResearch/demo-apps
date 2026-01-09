//
//  swiftui_example_tapresearchApp.swift
//  swiftui-example-tapresearch
//
//  Created by Jeroen Verbeek on 2/9/24.
//

import SwiftUI
import TapResearchSDK

struct MainContent: View {

	let tapSDKDelegates: TapResearchSDKDelegates
	// API token for example is no in TapResearchToken.swift
	@State var userId: String = "public-demo-user" // Replace with your own app's player user id

	init() {

		tapSDKDelegates = TapResearchSDKDelegates()

		let dict: [String:Any] = ["app-user": userId, "roller-type": "high", "roller-type-valid-until": Date().timeIntervalSince1970 + (3.0 * 60.0 * 60.0)]
		TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userId, userAttributes: dict, clearPreviousAttributes: true, sdkDelegate: self.tapSDKDelegates) { (error: Error?) in
			if let error = error {
				print(error.localizedDescription as Any)
			}
			else {
				print("Intialized - waiting to be ready")
			}
		}

		// Initialize withour sending user attributes:
		//TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userId, sdkDelegate: self.tapSDKDelegates) { (error: NSError?) in
		//	if let error = error {
		//		print("\(#function): \(error.code), \(error.localizedDescription)")
		//	}
		//}
	}

	var body: some View {
		ContentView(userId: $userId)
	}

}
