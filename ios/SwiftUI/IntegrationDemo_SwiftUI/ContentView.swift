//
//  ContentView.swift
//  TestApp_SwiftUI
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import SwiftUI
import TapResearchSDK

struct ContentView: View {

	@State var placementTagInput = ""
	@Binding var userId: String
	@State var knownPlacements = [
		"awesome-zone",
		"default-placement",
		"interstitial-placement",
		"floating-interstitial-placement",
		"capped-and-paced-interstitial",
		"banner-placement"
	]

	let contentDelegate: TapResearchContentDelegates = TapResearchContentDelegates()

	func showPlacement(_ placementTag: String) {

		guard placementTag.count > 0 else { return }

		if TapResearch.canShowContent(forPlacement: placementTag, error: { (error: NSError?) in
			// Do something with the error, this is an optional error block.
		}) {
			if !knownPlacements.contains(placementTag) {
				knownPlacements.append(placementTag)
			}
			let customParameters = ["param1": 123, "param2": "abc"] as [String : Any]
			TapResearch.showContent(forPlacement: placementTag, delegate: contentDelegate, customParameters: customParameters) { (error: NSError?) in
				// Do something with the error, this is an optional completion block.
			}
		}
		else {
			print("Placement \(placementTag) not ready")
		}
	}

	func updateuserIdInput(_ userIdInput: String) {

		guard userIdInput.count > 0 else { return }
		TapResearch.setUserIdentifier(userIdInput) { (error: NSError?) in
			// Send user attributes when you need to
			if let error = TapResearch.sendUserAttributes(attributes: ["app-user": userIdInput, "roller-type": "high", "roller-type-valid-until": Date().timeIntervalSince1970 + (3.0 * 60.0 * 60.0)]) {
				// Do something on completion or with the error
			}
		}
	}

	var body: some View {

		VStack {
			VStack {
				HStack {
					TextField("Placement Tag", text: $placementTagInput)
						.textFieldStyle(.roundedBorder)
						.autocapitalization(.none)
						.onChange(of: placementTagInput) { _ in
							if placementTagInput.filter({ $0.isNewline }).isEmpty {
								showPlacement(placementTagInput.replacingOccurrences(of: "\n", with: ""))
							}
						}

					Button(action: { showPlacement(placementTagInput) } ) {
						Text("Show Placement")
							.frame(minWidth: 130, maxWidth: 130)
					}
					.buttonStyle(.borderedProminent)
				}

				HStack {
					TextField("User Id", text: $userId)
						.textFieldStyle(.roundedBorder)
						.onChange(of: userId) { _ in
							if userId.filter({ $0.isNewline }).isEmpty {
								updateuserIdInput(userId.replacingOccurrences(of: "\n", with: ""))
							}
						}
					Button(action: { updateuserIdInput(userId) } ) {
						Text("Update User Id")
							.frame(minWidth: 130, maxWidth: 130)
					}
					.buttonStyle(.borderedProminent)
				}
			}
			.padding()

			List {
				Section("Known Placments") {
					ForEach(knownPlacements, id: \.self) { placementTag in
						Text(placementTag)
							.onTapGesture {
								showPlacement(placementTag)
							}
					}
				}
			}
			.listStyle(.plain)
			.cornerRadius(7, antialiased: true)
		}
	}

}

//MARK: - Preview

struct ContentView_Previews: PreviewProvider {

	@State static var userId: String = "public-demo-test-user"

	static var previews: some View {
		ContentView(userId: $userId)
	}

}
