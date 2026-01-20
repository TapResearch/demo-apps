//
//  ContentView.swift
//  SWPDemo_SwiftUI
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import SwiftUI
import TapResearchSDK

struct ContentView: View {

	var userId: String = "public-demo-test-user-for-2026" // Replace with a unique identifier
	let apiToken: String = "YOUR_API_TOKEN" // Replace with your own token
	let surveysPlacement: String = "earn-center"
	@State var showSurveyWallPreview: Bool = false
	@State var hasSurveys: Bool = false

	@StateObject var tapSDKDelegates: TapSDKDelegates = TapSDKDelegates()

	//MARK: -
	var body: some View {
		VStack {
			if self.tapSDKDelegates.isReady {
				Text("Survey Wall Preview Demo")
					.font(.headline)
				Text("Make sure to set a unique user identifier and pass it into SDK initialization!")
					.padding(EdgeInsets(top: 10, leading: 40, bottom: 20, trailing: 40))
				Button(hasSurveys ? "Show Survey Wall Preview" : "Has surveys for Survey Wall Preview?") {
					if hasSurveys {
						showSurveyWallPreview.toggle()
						hasSurveys = false
					}
					else {
						hasSurveys = TapResearch.hasSurveys(for: surveysPlacement) { (error: Error?) in
							// Handle any error in this optional errot handler.
						}
					}
				}.buttonStyle(.borderedProminent)
			}
			else {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle(tint: .blue))
					.scaleEffect(2.0, anchor: .center)
			}
		}
		.fullScreenCover(isPresented: $showSurveyWallPreview, content: {
			VStack {
				Text("Survey Wall Preview")
				SurveyWallPreview(showSurveyWallPreview: $showSurveyWallPreview)
			}.frame(maxWidth: .infinity, maxHeight: .infinity)
		})
		.onAppear() {
			// Initialize TapResearchSDK
			TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userId, sdkDelegate: self.tapSDKDelegates) { (error: Error?) in
				if let error = error {
					print(error.localizedDescription as Any)
				}
				else {
					print("Intialized - waiting to be ready")
				}
			}
		}
	}

}

//MARK: -
class TapSDKDelegates : NSObject, ObservableObject, TapResearchSDKDelegate {

	@Published var isReady: Bool = false

	///
	/// The SDK will call this callback to notify us of any errors that may occur.
	///
	func onTapResearchDidError(_ error: NSError) {
		print("\(#function) Error: \(error.code) \(error.localizedDescription)")
	}

	///
	/// After we initialize the SDK we need to wait for the SDK to report that it is ready for calls to SDK interfaces.
	///
	func onTapResearchSdkReady() {
		print("\(#function) SDK is ready")
		//
		// Set our reward handler.
		//
		TapResearch.setRewardDelegate(TapRewardDelegate())
		isReady = true
	}

}

//MARK: -
class TapRewardDelegate : NSObject, TapResearchRewardDelegate {

	///
	/// Users receive rewards for completing surveys, this callback receives those.
	///
	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("\(#function): \(rewards.count) rewards awarded")
	}

}

//MARK: - Preview
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
