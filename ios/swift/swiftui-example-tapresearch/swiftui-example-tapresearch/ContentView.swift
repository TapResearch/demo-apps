//
//  ContentView.swift
//  TestApp_SwiftUI
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import SwiftUI
import TapResearchSDK

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
struct ContentView: View {

    @State var placementTagInput = ""
    @State var userIdInput = "some-userid-to-be-replaced"
    @State var knownPlacements = [
        "default-placement",
        "interstitial-placement",
        "banner-placement"
    ]

    let apiKey = "ed51703ae058f16bd196a81f9fc1bfcb"
    let tapResearchDelegates: TapResearchDelegates!

    ///---------------------------------------------------------------------------------------------
    init() {
        print("Using api key \(apiKey)")
        tapResearchDelegates = TapResearchDelegates()
        TapResearchSDK.initialize(withAPIToken: apiKey, userIdentifier: userIdInput, sdkDelegate: tapResearchDelegates) { (error: TRError?) in
            if ((error) != nil) {
                print("Error \(String(describing: error))")

            }
        }
    }

    ///---------------------------------------------------------------------------------------------
    func showPlacement(_ placementTag: String) {

        guard placementTag.count > 0 else { return }

        if TapResearchSDK.canShowContent(forPlacement: placementTag) {
            if !knownPlacements.contains(placementTag) {
                knownPlacements.append(placementTag)
            }
            TapResearchSDK.showContent(forPlacement: placementTag, delegate: self.tapResearchDelegates)
        }
    }

    ///---------------------------------------------------------------------------------------------
    func updateUserId(_ userId: String) {

        guard userId.count > 0 else { return }
        TapResearchSDK.setUserIdentifier(userId)
    }

    ///---------------------------------------------------------------------------------------------
    var body: some View {
        VStack {
            VStack {
                HStack {
                    TextField("Placement Tag", text: $placementTagInput)
                        .textFieldStyle(.roundedBorder)
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
                    TextField("User Id", text: $userIdInput)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: userIdInput) { _ in
                            if userIdInput.filter({ $0.isNewline }).isEmpty {
                                updateUserId(userIdInput.replacingOccurrences(of: "\n", with: ""))
                            }
                        }
                    Button(action: { updateUserId(userIdInput) } ) {
                        Text("Update User Id")
                            .frame(minWidth: 130, maxWidth: 130)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }.padding()

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

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
class TapResearchDelegates : TapResearchSDKDelegate, TapResearchContentDelegate {

    ///---------------------------------------------------------------------------------------------
    func onTapReseachDidError(_ error: TRError) {
        print("\(#function): \(error.code), \(error.localizedDescription)")
    }

    ///---------------------------------------------------------------------------------------------
    func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
        print("\(#function): \(rewards.count) rewards awarded")
    }

    ///---------------------------------------------------------------------------------------------
    func onTapResearchContentShown(forPlacement placement: String) {
        print("\(#function): \(placement) was shown")
    }

    ///---------------------------------------------------------------------------------------------
    func onTapResearchContentDismissed(forPlacement placement: String) {
        print("\(#function): \(placement) was dismissed")
    }

}

///---------------------------------------------------------------------------------------------
///---------------------------------------------------------------------------------------------
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
