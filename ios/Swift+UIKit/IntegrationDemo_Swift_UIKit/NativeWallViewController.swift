//
//  NativeWallViewController.swift
//  TestApp_Swift_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import UIKit
import TapResearchSDK

class NativeWallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TapResearchContentDelegate, TapResearchSurveysDelegate {

	var placementTag: String!
	var surveys: [TRSurvey] = []

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var networkBanner: UIView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!

	override func viewDidLoad() {
		super.viewDidLoad()

		surveys = TapResearch.getSurveys(for: placementTag)
		if surveys.count > 0 {
			spinner.hidesWhenStopped = true
			spinner.stopAnimating()
		}
		TapResearch.setSurveysDelegate(self)
	}

	//MARK: - Table delegate and datasource

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		self.tableView.deselectRow(at: indexPath, animated: true)

		let surveyId = surveys[indexPath.row].surveyIdentifier
		if TapResearch.canShowSurvey(surveyId: surveyId, forPlacementTag: placementTag) {
			TapResearch.showSurvey(surveyId: surveyId, placementTag: placementTag, delegate: self, customParameters: ["key":"value"]) { (error: NSError?) in
			TapResearch.showSurvey(surveyId: surveyId, placementTag: placementTag, delegate: self) { (error: NSError?) in
				if let error = error {
					print("Error: \(error.userInfo[TapResearch.TapResearchErrorCodeString] ?? "(No code)") \(error.localizedDescription)")
					// do something with the error
				}
			}
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return surveys.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let survey: TRSurvey = surveys[indexPath.row]
		let title: String = placementTag + " " + survey.surveyIdentifier
		let info: String = "\(survey.lengthInMinutes) \(survey.lengthInMinutes == 1 ? "minute" : "minutes"), \(survey.rewardAmount) \(survey.currencyName)"
		return PlacementCell.cell(tableView: tableView, placement:title, info: info)
	}

	//MARK: - TapResearch survey delegates

	/// ---------------------------------------------------------------------------------------------
	func onTapResearchSurveysRefreshed(forPlacement placementTag: String) {
		print("placement surveys refreshed for \(placementTag)")

		surveys = TapResearch.getSurveys(for: placementTag)
		tableView.reloadData()
		if surveys.count > 0 {
			spinner.hidesWhenStopped = true
			spinner.stopAnimating()
		}
	}

	//MARK: - TapResearch content delegates

	func onTapResearchContentShown(forPlacement placement: String) {
		print("[\(Date())] onTapResearchContentShown(\(placement))")
	}

	func onTapResearchContentDismissed(forPlacement placement: String) {
		print("[\(Date())] onTapResearchContentDismissed(\(placement))")
		DispatchQueue.main.async(execute: { () -> Void in
		})
	}

}
