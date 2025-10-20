//
//  TapResearchSDKDelegates.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 11/9/23.
//

import Foundation
import TapResearchSDK

class TapResearchDelegates: NSObject, TapResearchSDKDelegate, LogPrint {

	// Optional
//	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
//		logPrint("number of rewards = \(rewards.count)")
//	}

	// Optional
//	func onTapResearchQuickQuestionResponse(_ qqPayload: TRQQDataPayload) {
//		logPrint()
//	}

	func onTapResearchDidError(_ error: NSError) {
		logPrint("\(error.code) \(error.localizedDescription)")
	}

	func onTapResearchSdkReady() {
		logPrint()
		NotificationCenter.default.post(name: Notification.Name("refresh"), object: nil)
		if let error: NSError = TapResearch.sendUserAttributes(attributes: ["Number" : 12, "String" : "Some text", "Boolean" : "true"], clearPreviousAttributes: false) {
			logPrint("Error sending user attributes: \(error.code) \(error.localizedDescription)")
		}
	}

}
