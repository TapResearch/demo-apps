//
//  SurveyWallPreview.swift
//  IntegrationDemo_SwiftUI
//
//  Created by Jeroen Verbeek on 12/18/24.
//

import SwiftUI
import TapResearchSDK

class SurveysRefresher: ObservableObject, TapResearchSurveysDelegate {

	@Published var surveys: [TRSurvey] = []

	func onTapResearchSurveysRefreshed(forPlacement placementTag: String) {
		refresh()
	}

	func refresh() {
		self.surveys.append(contentsOf:  TapResearch.getSurveys(for: "earn-center") {_ in })
	}

}

struct SurveyWallPreview: View {

	@StateObject var surveysRefresher: SurveysRefresher = SurveysRefresher()
	@Binding var showSurveyWallPreview: Bool

	let contentDelegate: TapResearchContentDelegates = TapResearchContentDelegates()

	func showSurvey(_ surveyId: String) {

		TapResearch.showSurvey(surveyId: surveyId, placementTag: "earn-center", delegate: contentDelegate) { (error: NSError?) in
			if let error = error {
				print("Error: \(error.userInfo[TapResearch.TapResearchErrorCodeString] ?? "(No code)") \(error.localizedDescription)")
				// do something with the error
			}
		}
	}

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
				LazyHGrid(rows: [GridItem(.flexible(minimum: ((geo.size.width - 20) / 2), maximum: ((geo.size.width - 20) / 2)), spacing: 10),
								 GridItem(.flexible(minimum: ((geo.size.width - 20) / 2), maximum: ((geo.size.width - 20) / 2)), spacing: 10)],
						  spacing: 10) {
					ForEach($surveysRefresher.surveys, id: \.self) { survey in
						VStack {
							let string = "\(survey.wrappedValue.rewardAmount) \(survey.wrappedValue.currencyName)\nfor \(survey.wrappedValue.lengthInMinutes) minutes"
							Text(string).font(.title).foregroundStyle(Color.white)
						}
						.frame(width: ((geo.size.width - 20) / 2), height: ((geo.size.width - 20) / 2))
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

}
