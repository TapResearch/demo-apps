//
//  ViewController.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import UIKit
import TapResearchSDK

class ViewController : UIViewController,
					   UITextFieldDelegate,
					   UITableViewDelegate,
					   UITableViewDataSource,
					   TapResearchContentDelegate,
					   TapResearchGrantBoostResponseDelegate,
					   LogPrint
{

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var placementTextField: UITextField!
	@IBOutlet weak var placementStatus: UILabel!
	@IBOutlet weak var boostTextField: UITextField!
	@IBOutlet weak var boostStatus: UILabel!

	// Token for example is in TapResearchToken.swift
	let userIdentifier: String = "public-demo-test-user-for-2026" // Replace with your own app's player user id
	let tapDelegates: TapResearchDelegates = TapResearchDelegates()
	var surveysPlacement: String = "earn-center"
	let showSurveysSegue: String = "ShowSurveys"
	var knownPlacements: [String] = [
		"earn-center",
		"default-placement",
		"interstitial-placement",
		"banner-placement",
		"floating-interstitial-placement"
	]

	override func viewDidLoad() {
		super.viewDidLoad()

		// Initialize TapResearch
//		let dict: [String:Any] = ["some_string" : "a string value", "some_number" : 12]
		TapResearch.initialize(withAPIToken: apiToken,
							   userIdentifier: userIdentifier,
//							   userAttributes: dict,
//							   clearPreviousAttributes: true,
							   sdkDelegate:tapDelegates) { (error: Error?) in
			if let error = error {
				self.logPrint(error.localizedDescription)
			}
			else {
				self.logPrint("Intialized - waiting to be ready")
			}
		}

		placementTextField.placeholder = "Placement Tag"
		placementTextField.delegate = self
		boostTextField.placeholder = "Boost Tag"
		boostTextField.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profiler", style: .plain, target: self, action: #selector(showProfiler))
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Surveys?", style: .plain, target: self, action: #selector(refresh))
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == showSurveysSegue {
			if let vc: NativeWallViewController = segue.destination as? NativeWallViewController {
				vc.placementTag = surveysPlacement
			}
		}
	}
	
	//MARK: - UITextFieldDelegate

	func textFieldDidChangeSelection(_ textField: UITextField) {

		switch textField {
			case boostTextField:
				if let _ = boostStatus.text {
					boostStatus.text = nil
				}
			case placementTextField:
				if let _ = placementStatus.text {
					placementStatus.text = nil
				}
			default:
				return
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		switch textField {
			case boostTextField:
				grantBoost()
				return true
			case placementTextField:
				showPlacement()
				return true
			default:
				return false
		}
	}

	//MARK: - Actions and button handlers

	@objc func refresh() {
		tableView.reloadData()
	}

	@objc func showProfiler() {
		DispatchQueue.main.async(execute: { () -> Void in
			self.presentProfilingQuestionnaire(apiToken: apiToken, userIdentifier: self.userIdentifier)
		})
	}

	@IBAction func grantBoost() {
		guard let text: String = boostTextField.text else { return }

		TapResearch.grantBoost(text, delegate: self) { (error: NSError?) in
			if let error {
				self.boostStatus.text = "\(error.code) \(error.localizedDescription)"
			}
		}
	}

	@IBAction func showPlacement() {
		guard let text: String = placementTextField.text else { return }

		let canShow: Bool = TapResearch.canShowContent(forPlacement: text) { (error: NSError?) in
			// Handle error, this is an optional error block, if there is an error false is returned by function.
		}
		if canShow {
			//let customParameters = ["param1": 123, "param2": "abc"] as [String : Any]
			TapResearch.showContent(forPlacement: text, delegate: self/*, customParameters: customParameters*/) { (error: NSError?) in
				if let error = error {
					self.placementStatus.text = "\(error.code) \(error.localizedDescription)"
				}
				else {
					if !(self.knownPlacements as NSArray).contains(text) {
						self.knownPlacements.append(text)
						DispatchQueue.main.async(execute: { () -> Void in
							self.tableView.reloadData()
						})
					}
				}
			}
		}
		else {
			placementStatus.text = "No content for placement"
		}
	}

	//MARK: - Table delegate and datasource
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)

		if indexPath.section == 1 {
			performSegue(withIdentifier: showSurveysSegue, sender: surveysPlacement)
			return
		}

		if TapResearch.canShowContent(forPlacement: knownPlacements[indexPath.row]) {
			TapResearch.showContent(forPlacement: knownPlacements[indexPath.row], delegate: self, customParameters: ["custom_param_1" : "test text", "custom_param_3" : 12]) { (error: NSError?) in
                if let error = error {
					self.logPrint("Error on showContent: \(error.code) \(error.localizedDescription)")
                }
			}
		}
		else {
			logPrint("Placement not ready")
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int {

		if TapResearch.hasSurveys(for: surveysPlacement) {
			return 2
		}
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if section == 1 {
			return 1
		}
		return knownPlacements.count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if section == 1 {
			return "Surveys"
		}
		return "Placements"
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if indexPath.section == 1 {
			return PlacementCell.cell(tableView: tableView, indexPath: indexPath, placement: surveysPlacement)
		}
		return PlacementCell.cell(tableView: tableView, indexPath: indexPath, placement: knownPlacements[indexPath.row])
	}

	//MARK: - TapResearchContentDelegate

	func onTapResearchContentShown(forPlacement placement: String) {
		logPrint("placement = \(placement)")

	}

	func onTapResearchContentDismissed(forPlacement placement: String) {
		logPrint("placement = \(placement)")
		//print("ViewController.onTapResearchContentDismissed(\(placement))")
	}

	//MARK: - TapResearchGrantBoostResponseDelegate

	func onTapResearchGrantBoostResponse(_ response: TapResearchSDK.TRGrantBoostResponse) {

		if response.success {
			self.boostStatus.text = "\(response.boostTag): success!"
		}
		else {
			if let error = response.error {
				self.boostStatus.text = "\(response.boostTag): \(error.localizedDescription)"
			}
			else {
				self.boostStatus.text = "\(response.boostTag): unkown error"
			}
		}
	}

//	func presentProfilingQuestionnaire(apiToken: String, userIdentifier: String) {
//		Task { @MainActor in
//			do {
//				let initialResponse = try await TapResearch.getProfilingQualificationsAsync(
//					apiToken: apiToken,
//					userIdentifier: self.userIdentifier,
//					countryCode: "US"
//				)
//
//				let questionnaire = TRQualificationViewController(
//					response: initialResponse,
//					submitHandler: { answers in
//						try await TapResearch.sendProfilingAnswersAsync(
//							apiToken: apiToken,
//							userIdentifier: userIdentifier,
//							answers: answers,
//							countryCode: "US"
//						)
//					},
//					onExit: { [weak self = self] in
//						DispatchQueue.main.async(execute: { () -> Void in
//							self?.dismiss(animated: true)
//						})
//					},
//					onComplete: { [weak self = self] finalResponse in
//						print("Profiling complete: \(finalResponse.isProfiled)")
//						DispatchQueue.main.async(execute: { () -> Void in
//							self?.dismiss(animated: true)
//						})
//					}
//				)
//
//				DispatchQueue.main.async(execute: { () -> Void in
//					let navigationController = UINavigationController(rootViewController: questionnaire)
//					navigationController.modalPresentationStyle = .formSheet
//					self.present(navigationController, animated: true)
//				})
//
//			} catch {
//				DispatchQueue.main.async(execute: { () -> Void in
//					let alert = UIAlertController(
//						title: "Unable to load profiling",
//						message: error.localizedDescription,
//						preferredStyle: .alert
//					)
//					alert.addAction(UIAlertAction(title: "OK", style: .default))
//					self.present(alert, animated: true)
//				})
//			}
//		}
//	}

}
@MainActor
extension UIViewController {

	func presentProfilingQuestionnaire(
		apiToken: String,
		userIdentifier: String
	) {
		Task { @MainActor in
			do {
				let initialResponse = try await TapResearch.getProfilingQualificationsAsync(
					apiToken: apiToken,
					userIdentifier: UUID().uuidString,
					countryCode: "US"
				)

				// Do not present an empty questionnaire for a user who is
				// already fully profiled (or has no remaining qualifications).
				guard !initialResponse.isProfiled,
					  !initialResponse.qualifications.isEmpty else {
					print("Profiling already complete: \(initialResponse.isProfiled)")
					return
				}

				let questionnaire = TRQualificationViewController(
					response: initialResponse,
					submitHandler: { answers in
						try await TapResearch.sendProfilingAnswersAsync(
							apiToken: apiToken,
							userIdentifier: userIdentifier,
							answers: answers,
							countryCode: "US"
						)
					},
					onExit: { [weak self] in
						self?.dismiss(animated: true)
					},
					onComplete: { [weak self] finalResponse in
						print("Profiling complete: \(finalResponse.isProfiled)")
						self?.dismiss(animated: true)
					}
				)

				let navigationController = UINavigationController(rootViewController: questionnaire)
				navigationController.modalPresentationStyle = .formSheet
				present(navigationController, animated: true)

			} catch {
				let alert = UIAlertController(
					title: "Unable to load profiling",
					message: error.localizedDescription,
					preferredStyle: .alert
				)
				alert.addAction(UIAlertAction(title: "OK", style: .default))
				present(alert, animated: true)
			}
		}
	}
}
