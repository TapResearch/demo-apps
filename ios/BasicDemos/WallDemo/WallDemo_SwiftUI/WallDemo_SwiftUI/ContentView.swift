//
//  ContentView.swift
//  TestApp_SwiftUI
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import SwiftUI
import TapResearchSDK

struct ContentView: View {

	var userId: String = "public-demo-test-user-for-2026" // Replace with a unique identifier
	let apiToken: String = "YOUR_API_TOKEN" // Replace with your own token
	let wallPlacement: String = "earn-center"

	@StateObject var tapSDKDelegates: TapSDKDelegates = TapSDKDelegates()

	//MARK: -
	var body: some View {

		VStack {
			if self.tapSDKDelegates.isReady {
				Text("Wall Demo")
					.font(.headline)
				Text("Make sure to set a unique user identifier and pass it into SDK initialization!")
					.padding(EdgeInsets(top: 10, leading: 40, bottom: 20, trailing: 40))
				Button("Show Wall") {
					showPlacement(wallPlacement)
				}.buttonStyle(.borderedProminent)
			}
			else {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle(tint: .blue))
					.scaleEffect(2.0, anchor: .center)
			}
		}
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

	//MARK: -
	func showPlacement(_ placementTag: String) {
		guard placementTag.count > 0 else { return }

		///
		/// Before attempting to present a placement's content we first check if the placement currently has content available.
		///
		if TapResearch.canShowContent(forPlacement: placementTag, error: { (error: NSError?) in
			// Do something with the error, this is an optional error block.
			if let error {
				print("\(#function) Error: \(error.code) \(error.localizedDescription)")
			}
		}) {
			///
			/// Tell the SDK to present the placement's content, passing in a content delegates object:
			///
			TapResearch.showContent(forPlacement: placementTag, delegate: TapContentDelegates()) { (error: NSError?) in
				// Do something with the error, this is an optional error block.
				if let error {
					print("\(#function) Error: \(error.code) \(error.localizedDescription)")
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
		TapResearch.setRewardDelegate(TapRewardDelegate())
		isReady = true
	}

}

//MARK: -
class TapContentDelegates : NSObject, TapResearchContentDelegate {

	///
	/// When any TapResearch content is presented `onTapResearchContentShown` is called, followed by the presenting content's `viewWillAppear`.
	///
	func onTapResearchContentShown(forPlacement placement: String) {
		print("[\(Date())] \(#function): \(placement) was shown")
	}

	///
	/// When any TapResearch content is dismissed `onTapResearchContentDismissed` is called, followed by the presented content's `viewWillDisappear`.
	///
	func onTapResearchContentDismissed(forPlacement placement: String) {
		print("[\(Date())] \(#function): \(placement) was dismissed")
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
