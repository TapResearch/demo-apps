//
//  SurveyWallPreview.swift
//  SWPDemo_SwiftUI
//
//  Created by Jeroen Verbeek on 12/18/24.
//

import SwiftUI
import TapResearchSDK

struct SurveyWallPreview: View {

	@StateObject var surveysRefresher: SurveysRefresher = SurveysRefresher()
	@Binding var showSurveyWallPreview: Bool

	let contentDelegate: TapContentDelegates = TapContentDelegates()

	var body: some View {

		GeometryReader { geo in
			VStack {
				Button(action: {
					showSurveyWallPreview = false
				}) {
					Text("Back")
				}
				.frame(width: 50, height: 40)
				.padding(.top, 100)
				let size = ((geo.size.width - 40) / 2)
				LazyHGrid(rows: [GridItem(.flexible(minimum: size, maximum: size), spacing: 10),
								 GridItem(.flexible(minimum: size, maximum: size), spacing: 10)],
						  spacing: 10) {
					ForEach($surveysRefresher.surveys, id: \.self) { survey in
						VStack {
							Text(surveyTitle(survey.wrappedValue)).foregroundStyle(Color.white)
						}
						.frame(width: size, height: size)
						.background(RoundedRectangle(cornerSize: CGSize(width: 10.0, height: 10.0)).fill(Color.accentColor))
						.onTapGesture {
							self.showSurvey(survey.wrappedValue.surveyIdentifier)
						}
					}
				}
				.frame(width: geo.size.width, height: geo.size.height)
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
			.background(Color.white)
			.onAppear {
				TapResearch.setSurveysDelegate(surveysRefresher)
				surveysRefresher.refresh()
			}
		}
	}

	func showSurvey(_ surveyId: String) {

		TapResearch.showSurvey(surveyId: surveyId, placementTag: "earn-center", delegate: contentDelegate) { (error: NSError?) in
			if let error = error {
				print("Error: \(error.userInfo[TapResearch.TapResearchErrorCodeString] ?? "(No code)") \(error.localizedDescription)")
				// do something with the error
			}
		}
	}

	func surveyTitle(_ survey: TRSurvey) -> String {

		var string: String = "\(survey.rewardAmount) \(survey.currencyName)\nfor \(survey.lengthInMinutes) minutes"
		if survey.isSale {
			string += String(format:"\n🛍️ X  %.2f", survey.saleMultiplier)
		}
		if survey.isHotTile {
			string += "\n🔥🔥"
		}
		return string
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
class SurveysRefresher: ObservableObject, TapResearchSurveysDelegate {

	@Published var surveys: [TRSurvey] = []

	///
	/// This is called when the SDK has a new set of surveys available. This is a required delegate.
	/// In this delegate you should call `TapResearch.getSurveys(for: "your-placement")` and update your surveys display.
	/// Not updating your surveys display when you receive this callback will result in expired or otherwise unavailable surveys.
	///
	func onTapResearchSurveysRefreshed(forPlacement placementTag: String) {
		refresh()
	}

	func refresh() {
		self.surveys = TapResearch.getSurveys(for: "earn-center") { _ in }
	}

}
