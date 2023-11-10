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

		if let error: NSError = TapResearchSDK.sendUserAttributes(attributes: ["attribute1" : "some player attribute", "a_number" : 12]) {
			print("sendUserAttributes: \(error.code) \(error.localizedDescription)")
		}
		print("onTapResearchSdkReady()")
	}

}
