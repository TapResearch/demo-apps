//
//  swiftui_example_tapresearchApp.swift
//  swiftui-example-tapresearch
//
//  Created by Michael Quinn on 5/20/23.
//

import SwiftUI
import TapResearchSDK

@main
struct swiftui_example_tapresearchApp: App {

	let apiKey = "0b5dcbae8151c1b82d69697dce004bf2"
	var userIdInput = "public-demo-test-user"
	var tapSDKDelegates: TapResearchSDKDelegates! = TapResearchSDKDelegates()

	///---------------------------------------------------------------------------------------------
	init() {

		tapSDKDelegates = TapResearchSDKDelegates()
		TapResearchSDK.initialize(withAPIToken: apiKey, userIdentifier: userIdInput, sdkDelegate: tapSDKDelegates) { (error: TRError?) in
			if ((error) != nil) {
				print("Error \(String(describing: error))")
			}
		}
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
class TapResearchSDKDelegates : TapResearchSDKDelegate {

	///---------------------------------------------------------------------------------------------
	func onTapResearchDidError(_ error: TRError) {
		print("(TRError) \(#function): \(error.code), \(error.localizedDescription)")
	}

	///---------------------------------------------------------------------------------------------
	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("(TRError) \(#function): \(rewards.count) rewards awarded")

		var i: Int = 0
		for reward in rewards {
			print("reward \(i): currency = \(reward.currencyName ?? "unknown"), amount = \(reward.rewardAmount)")
			i += 1
		}
	}

}


