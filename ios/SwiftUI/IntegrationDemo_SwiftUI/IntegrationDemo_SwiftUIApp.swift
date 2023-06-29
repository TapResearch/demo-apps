//
//  swiftui_example_tapresearchApp.swift
//  swiftui-example-tapresearch
//
//  Created by Michael Quinn on 5/20/23.
//

import SwiftUI
import TapResearchSDK

@main
class swiftui_example_tapresearchApp: App {

	let sdkToken: String = "0b5dcbae8151c1b82d69697dce004bf2"
	let userId: String = "public-demo-test-user"

	let tapSDKDelegates: TapResearchSDKDelegates

	var body: some Scene {
		WindowGroup {
            ContentView().onAppear(perform: { [self] in
                TapResearchSDK.initialize(withAPIToken: self.sdkToken, userIdentifier: self.userId, sdkDelegate: self.tapSDKDelegates) { (error: TRError?) in
                    if let e = error {
                        print("\(#function): \(e.code), \(e.localizedDescription)")
                    }
                }
			})
		}
	}

	///---------------------------------------------------------------------------------------------
	required init() {
		tapSDKDelegates = TapResearchSDKDelegates()
	}

}

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
class TapResearchSDKDelegates : TapResearchSDKDelegate {

	///---------------------------------------------------------------------------------------------
	func onTapResearchDidError(_ error: TRError) {
		print("\(#function): \(error.code), \(error.localizedDescription)")
	}

	///---------------------------------------------------------------------------------------------
	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("\(#function): \(rewards.count) rewards awarded")
	}

}
