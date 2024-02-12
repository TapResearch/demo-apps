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
