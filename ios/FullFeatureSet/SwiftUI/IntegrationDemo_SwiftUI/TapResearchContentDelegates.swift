//
//  TapResearchContentDelegates.swift
//  IntegrationDemo_SwiftUI
//
//  Created by Jeroen Verbeek on 2/9/24.
//

import Foundation
import TapResearchSDK

class TapResearchContentDelegates : NSObject, TapResearchContentDelegate {

	func onTapResearchContentShown(forPlacement placement: String) {
		print("[\(Date())] \(#function): \(placement) was shown")
	}

	func onTapResearchContentDismissed(forPlacement placement: String) {
		print("[\(Date())] \(#function): \(placement) was dismissed")
	}

}

class TapResearchBoostDelegate : NSObject, TapResearchGrantBoostResponseDelegate {

	func onTapResearchGrantBoostResponse(_ response: TapResearchSDK.TRGrantBoostResponse) {

		if response.success {
			print("[\(Date())] \(#function): \(response.boostTag): success!")
		}
		else {
			if let error = response.error {
				print("[\(Date())] \(#function): \(response.boostTag): \(error.localizedDescription)")
			}
			else {
				print("[\(Date())] \(#function): \(response.boostTag): unkown error")
			}
		}
	}

}
