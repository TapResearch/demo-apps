//
//  QualificationUIKit.swift
//  IntegrationDemo_SwiftUI
//
//  Created by Jeroen Verbeek on 09/08/26.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import TapResearchSDK

/// ---------------------------------------------------------------------------------------------
/// ---------------------------------------------------------------------------------------------
public enum TRQualificationUIKit {

	/// ---------------------------------------------------------------------------------------------
	/// Creates a UIViewController containing the SwiftUI questionnaire.
	/// The caller may present, push, or embed the returned controller.
	@MainActor
	public static func makeViewController(
		response: TRProfileResponse,
		submitHandler: @escaping TRQualificationViewModel.SubmitHandler,
		onExit: @escaping () -> Void,
		onComplete: @escaping (TRProfileResponse) -> Void
	) -> UIViewController {
		let view = TRQualificationSurveyView(
			response: response,
			submitHandler: submitHandler,
			onExit: onExit,
			onComplete: onComplete
		)

		return UIHostingController(rootView: view)
	}

	/// ---------------------------------------------------------------------------------------------
	/// Convenience modal presentation for UIKit callers.
	@MainActor
	public static func present(
		from presentingViewController: UIViewController,
		response: TRProfileResponse,
		submitHandler: @escaping TRQualificationViewModel.SubmitHandler,
		animated: Bool = true,
		onExit: (() -> Void)? = nil,
		onComplete: ((TRProfileResponse) -> Void)? = nil
	) {
		var host: UIViewController?

		host = makeViewController(
			response: response,
			submitHandler: submitHandler,
			onExit: { [weak presentingViewController] in
				host?.dismiss(animated: animated) {
					onExit?()
				}
				_ = presentingViewController
			},
			onComplete: { updatedResponse in
				host?.dismiss(animated: animated) {
					onComplete?(updatedResponse)
				}
			}
		)

		guard let host else { return }
		host.modalPresentationStyle = .formSheet
		presentingViewController.present(host, animated: animated)
	}

}

#endif
