//
//  ViewController.swift
//  SWPDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 1/5/26.
//

import TapResearchSDK
import UIKit

//MARK: - ViewController

class TapResearchBasicsController: UIViewController {

	let apiToken: String = "YOUR_API_TOKEN" // Replace with your own token
	let userIdentifier: String = "public-demo-test-user-for-2026"  // Replace with your own app's player user id

	let surveyWallPreviewPlacement: String = "earn-center"  // Replace with your own app's placement
	var surveyWallHasSurveys: Bool = false {
		didSet {
			DispatchQueue.main.async(execute: { () -> Void in
				if self.surveyWallHasSurveys {
					self.showSurveyWallPreviewButton.setTitle("Show Survey Wall Preview", for: .normal)
				}
				else {
					self.showSurveyWallPreviewButton.setTitle("Has surveys for Survey Wall Preview?", for: .normal)
				}
			})
		}
	}

	static let showSurveyWallPreviewSegue: String = "showSurveyWallPreview"

	@IBOutlet weak var buttonsContainer: UIView!
	@IBOutlet weak var showSurveyWallPreviewButton: UIButton!
	@IBOutlet weak var sdkReadySpinner: UIActivityIndicatorView!

	//MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		sdkReadySpinner.hidesWhenStopped = true
		sdkReadySpinner.startAnimating()
		buttonsContainer.isHidden = true
		surveyWallHasSurveys = false

		// Initialize TapResearchSDK
		TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userIdentifier, sdkDelegate: self) { (error: NSError?) in
			if let error {
				print("\(#function) Error: \(error.code) \(error.localizedDescription)")
			}
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == TapResearchBasicsController.showSurveyWallPreviewSegue {
			if let vc: SurveyWallPreviewController = segue.destination as? SurveyWallPreviewController {
				vc.placementTag = surveyWallPreviewPlacement
			}
		}
	}

	//MARK: - Button actions

	///
	/// We want to check if the Survey Wall Preview placement has surveys available,
	/// 	so we check on button tap and when we see that there are surveys available
	/// 	we update the button's title and the next tap will then present SurveyWallPreviewController.
	///
	@IBAction func showSurveyWallPreviewButtonTapped() {

		if surveyWallHasSurveys {
			performSegue(ithIdentifier: TapResearchBasicsController.showSurveyWallPreviewSegue, sender: surveyWallPreviewPlacement)
			surveyWallHasSurveys = false
		}
		else {
			let hasSurveys: Bool = TapResearch.hasSurveys(for: surveyWallPreviewPlacement) { (error: NSError?) in
				// This is an optional error block, if there is an error false is returned by function.
				if let error {
					print("\(#function) Error: \(error.code) \(error.localizedDescription)")
				}
			}
			if hasSurveys {
				surveyWallHasSurveys = true
			}
		}
	}

}

//MARK: - TapResearchRewardDelegate

extension TapResearchBasicsController: TapResearchRewardDelegate {

	///
	/// Users receive rewards for completing surveys, this callback receives those.
	///
	func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
		print("\(#function) Number of rewards = \(rewards.count)")
	}

}

//MARK: - TapResearchSDKDelegate

extension TapResearchBasicsController: TapResearchSDKDelegate {

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

		//
		// Set our reward handler.
		//
		TapResearch.setRewardDelegate(self)
		DispatchQueue.main.async(execute: { () -> Void in
			self.buttonsContainer.isHidden = false
			self.sdkReadySpinner.stopAnimating()
		})
	}

}
