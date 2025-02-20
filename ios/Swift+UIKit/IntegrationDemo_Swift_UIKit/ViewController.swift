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
//					   TapResearchRewardDelegate,
//					   TapResearchQuickQuestionDelegate,
					   LogPrint
{

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var placementStatus: UILabel!

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

		textField.placeholder = "Placement Tag"
		textField.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
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

		if let _ = placementStatus.text {
			placementStatus.text = nil
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		showPlacement()
		return true
	}

	//MARK: - Actions and button handlers

	@objc func refresh() {
		tableView.reloadData()
	}

	@IBAction func showPlacement() {
		guard let text: String = textField.text else { return }

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

}
