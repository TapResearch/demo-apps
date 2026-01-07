//
//  TapResearchSDKDelegates.swift
//  swiftui-example-tapresearch
//
//  Created by Jeroen Verbeek on 2/9/24.
//

import SwiftUI
import TapResearchSDK

class TapResearchSDKDelegates : NSObject, TapResearchSDKDelegate {

	func onTapResearchDidError(_ error: NSError) {
		print("\(#function): \(error.code), \(error.localizedDescription)")
	}

	func onTapResearchQuickQuestionResponse(_ qqPayload: TRQQDataPayload) {
		print("[\(Date())] onTapResearchQuickQuestionResponse(responses...) = \(qqPayload)")
	}

	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("\(#function): \(rewards.count) rewards awarded")
	}

	func onTapResearchSdkReady() {
		print("\(#function)")

		if let error: NSError = TapResearch.sendUserAttributes(attributes: ["Number" : 12, "String" : "Some text", "Boolean" : "true"]) {
			print("Error sending user attributes: \(error.code) \(error.localizedDescription)")
		}
	}

}
