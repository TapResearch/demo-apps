//
//  ExampleIntegration.swift
//  IntegrationDemo_SwiftUI
//
//  Created by Jeroen Verbeek on 09/08/26.
//

import Foundation
import SwiftUI
import UIKit
import TapResearchSDK

// MARK: - SwiftUI

/// ---------------------------------------------------------------------------------------------
/// ---------------------------------------------------------------------------------------------
struct HostView: View {

	let apiToken: String
    let userIdentifier: String

    @Environment(\.dismiss) private var dismiss
    @State private var response: TRProfileResponse?
    @State private var loadError: Error?
	@Binding var showProfiler: Bool

	/// ---------------------------------------------------------------------------------------------
	var body: some View {
        Group {
            if let profileResponse = response {

                TRQualificationSurveyView(
                    response: profileResponse,
                    submitHandler: { answers in
                        try await TapResearch.sendProfilingAnswersAsync(
                            apiToken: apiToken,
                            userIdentifier: userIdentifier,
							answers: answers,
							countryCode: "US"
                        )
                    },
                    onExit: {
                        dismiss()
						showProfiler = false
                    },
                    onComplete: { finalResponse in
                        // finalResponse.isProfiled will normally be true here.
                        dismiss()
						showProfiler = false
                    }
                )
            } else {
                ProgressView("Loading…")
                    .task {
                        do {
                            response = try await TapResearch.getProfilingQualificationsAsync(
                                apiToken: apiToken,
                                userIdentifier: userIdentifier,
								countryCode: "US"
                            )
                        } catch {
                            loadError = error
                        }
                    }
            }
        }
    }

}

/*
//MARK: - UIKit

 Task { @MainActor in
     do {
         let response = try await getProfilingQualificationsAsync(
             apiToken: apiToken,
             userIdentifier: userIdentifier
           )

         TRQualificationUIKit.present(
             from: self,
             response: response,
             submitHandler: { answers in
                 try await sendProfilingAnswersAsync(
                     apiToken: apiToken,
                     userIdentifier: userIdentifier,
                     answers: answers
                   )
               },
             onExit: {
                 print("Profiling exited")
               },
             onComplete: { finalResponse in
                 print("Profiling complete: \(finalResponse.isProfiled)")
               }
           )
       } catch {
         print("Failed to load profiling qualifications: \(error)")
       }
 }
*/
