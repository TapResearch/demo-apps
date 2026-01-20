//
//  ViewController.swift
//  WallDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 1/5/26.
//

import UIKit
import TapResearchSDK

//MARK: - ViewController

class TapResearchBasicsController : UIViewController {

	let apiToken: String = "YOUR_API_TOKEN" // Replace with your own token
	let userIdentifier: String = "public-demo-test-user-for-2026" // Replace with your own app's player user id

	let wallPlacement: String = "earn-center" // Replace with your own app's placement

	@IBOutlet weak var buttonsContainer: UIView!
	@IBOutlet weak var sdkReadySpinner: UIActivityIndicatorView!

	//MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		sdkReadySpinner.hidesWhenStopped = true
		sdkReadySpinner.startAnimating()
		buttonsContainer.isHidden = true
		
		// Initialize TapResearchSDK
		TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userIdentifier, sdkDelegate: self) { (error: NSError?) in
			if let error {
				print("\(#function) Error: \(error.code) \(error.localizedDescription)")
			}
		}
	}

	//MARK: - Button actions

	///
	/// Before attempting to present a placement's content we first check if the placement currently has content available.
	///
	@IBAction func showWallButtonTapped() {

		let canShow: Bool = TapResearch.canShowContent(forPlacement: wallPlacement) { (error: NSError?) in
			// This is an optional error block, if there is an error false is returned by function.
			if let error {
				print("\(#function) Error: \(error.code) \(error.localizedDescription)")
			}
		}
		if canShow {
			TapResearch.showContent(forPlacement: wallPlacement, delegate: self) { (error: NSError?) in
				if let error {
					print("\(#function) Error: \(error.code) \(error.localizedDescription)")
				}
			}
		}
		else {
			print("\(#function) Error: No content for placement")
		}
	}

}

//MARK: - TapResearchContentDelegate

extension TapResearchBasicsController : TapResearchContentDelegate {

	///
	/// When any TapResearch content is presented `onTapResearchContentShown` is called, followed by the presenting content's `viewWillAppear`.
	///
	func onTapResearchContentShown(forPlacement placement: String) {
		print("\(#function) Placement content shown")
	}

	///
	/// When any TapResearch content is dismissed `onTapResearchContentDismissed` is called, followed by the presented content's `viewWillDisappear`.
	///
	func onTapResearchContentDismissed(forPlacement placement: String) {
		print("\(#function) Placement content dismissed")
	}

}

//MARK: - TapResearchRewardDelegate

extension TapResearchBasicsController : TapResearchRewardDelegate {

	///
	/// Users receive rewards for completing surveys, this callback receives those.
	///
	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("\(#function) Number of rewards = \(rewards.count)")
	}

}

//MARK: - TapResearchSDKDelegate

extension TapResearchBasicsController : TapResearchSDKDelegate {

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

		TapResearch.setRewardDelegate(self)
		DispatchQueue.main.async(execute: { () -> Void in
			self.buttonsContainer.isHidden = false
			self.sdkReadySpinner.stopAnimating()
		})
	}

}
