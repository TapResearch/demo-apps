//
//  TapResearchSDKDelegates.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 11/9/23.
//

import Foundation
import TapResearchSDK

class TapResearchDelegates: TapResearchSDKDelegate {

	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("onTapResearchDidReceiveRewards(rewards...)")
	}

	func onTapResearchDidError(_ error: NSError) {
		print("onTapResearchDidError: \(error.code) \(error.localizedDescription)")
	}

	func onTapResearchSdkReady() {
		print("onTapResearchSdkReady()")

		if let error: NSError = TapResearch.sendUserAttributes(attributes: ["Number" : 12, "String" : "Some text", "Boolean" : "true"]) {
			print("Error sending user attributes: \(error.code) \(error.localizedDescription)")
		}
	}

}
