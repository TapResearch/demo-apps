//
//  ViewController.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import UIKit
import TapResearchSDK

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
class ViewController : UIViewController,
					   UITextFieldDelegate,
					   UITableViewDelegate,
					   UITableViewDataSource,
					   TapResearchContentDelegate
{

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var placementStatus: UILabel!

	var knownPlacements: [String] = [
        "default-placement",
        "interstitial-placement",
        "floating-interstitial-placement",
        "banner-placement"
	]

	///---------------------------------------------------------------------------------------------
	override func viewDidLoad() {
		super.viewDidLoad()

		textField.placeholder = "Placement Tag"
		textField.delegate = self
	}

	//MARK: - UITextFieldDelegate

	///---------------------------------------------------------------------------------------------
	func textFieldDidChangeSelection(_ textField: UITextField) {

		if let _ = placementStatus.text {
			placementStatus.text = nil
		}
	}

	///---------------------------------------------------------------------------------------------
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		showPlacement()
		return true
	}

	//MARK: - Actions and button handlers

	///---------------------------------------------------------------------------------------------
	@IBAction func showPlacement() {
		guard let text: String = textField.text else { return }

		if TapResearchSDK.canShowContent(forPlacement: text) {
            let customParameters = ["param1": 123, "param2": "abc"] as [String : Any]

			TapResearchSDK.showContent(forPlacement: text, delegate: self, customParameters: customParameters) { (error: TRError?) in
				if let error = error {
					self.placementStatus.text = "\(error.userInfo[TRError.TapResearchErrorCodeString] ?? "(No code)") \(error.localizedDescription)"
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
	
	///---------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)

		if TapResearchSDK.canShowContent(forPlacement: knownPlacements[indexPath.row]) {
			TapResearchSDK.showContent(forPlacement: knownPlacements[indexPath.row], delegate: self, customParameters: ["custom_param_1" : "test text", "custom_param_2" : "大家好", "custom_param_3" : 12]) { (error: TRError?) in
				print("Error on showContent: \(error?.userInfo[TRError.TapResearchErrorCodeString] ?? "(No code)") \(error?.localizedDescription ?? "No error description")")
			}
		}
		else {
			print("Placement not ready")
		}
	}
	
	//---------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return knownPlacements.count
	}

	///---------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Known Placements"
	}
	
	///---------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return PlacementCell.cell(tableView: tableView, placement: knownPlacements[indexPath.row])
	}

	//MARK: - TapResearchContentDelegate

	///---------------------------------------------------------------------------------------------
	func onTapResearchContentShown(forPlacement placement: String) {
		print("onTapResearchContentShown(\(placement))")
	}
	
	///---------------------------------------------------------------------------------------------
	func onTapResearchContentDismissed(forPlacement placement: String) {
		print("onTapResearchContentDismissed(\(placement))")
	}

}
