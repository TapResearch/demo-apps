//
//  SurveyWallPreviewController.swift
//  SWPDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import TapResearchSDK
import UIKit

class SurveyWallPreviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var placementTag: String!
	var surveys: [TRSurvey] = []

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!

	//MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		TapResearch.setSurveysDelegate(self)
		surveys = TapResearch.getSurveys(for: placementTag)
		if surveys.count > 0 {
			spinner.hidesWhenStopped = true
			spinner.stopAnimating()
		}
	}

	//MARK: - Table delegate and datasource

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		self.tableView.deselectRow(at: indexPath, animated: true)

		let surveyId = surveys[indexPath.row].surveyIdentifier
		if TapResearch.canShowSurvey(surveyId: surveyId, forPlacementTag: placementTag) {
			TapResearch.showSurvey(surveyId: surveyId, placementTag: placementTag, delegate: self) { (error: NSError?) in
				if let error {
					print("\(#function) Error: \(error.code) \(error.localizedDescription)")
				}
			}
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return surveys.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		// Here we return a cell that shows the various states of
		var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "SurveyCell")
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: "SurveyCell")
		}
		guard let cell else { return UITableViewCell() }

		let survey: TRSurvey = surveys[indexPath.row]
		let title: String = placementTag + " " + survey.surveyIdentifier
		var info: String = "\(survey.lengthInMinutes) \(survey.lengthInMinutes == 1 ? "minute" : "minutes"), \(survey.rewardAmount) \(survey.currencyName)"
		if survey.isSale {
			info += String(format: " 🛍️ X %.2f", survey.saleMultiplier)
		}
		if survey.isHotTile {
			info += " 🔥"
		}

		cell.textLabel?.text = title
		cell.detailTextLabel?.text = info

		return cell
	}

}

//MARK: - TapResearchSurveysDelegate

extension SurveyWallPreviewController: TapResearchSurveysDelegate {

	///
	/// This is called when the SDK has a new set of surveys available. This is a required delegate.
	/// In this delegate you should call `TapResearch.getSurveys(for: "your-placement")` and update your surveys display.
	/// Not updating your surveys display when you receive this callback will result in expired or otherwise unavailable surveys.
	///
	func onTapResearchSurveysRefreshed(forPlacement placementTag: String) {
		print("\(#function) Placement surveys refreshed")

		surveys = TapResearch.getSurveys(for: placementTag)
		tableView.reloadData()
		if surveys.count > 0 {
			spinner.hidesWhenStopped = true
			spinner.stopAnimating()
		}
	}

}

//MARK: - TapResearchContentDelegate

extension SurveyWallPreviewController : TapResearchContentDelegate {

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
