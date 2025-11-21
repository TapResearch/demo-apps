//
//  InformationAlert.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 11/21/25.
//

import UIKit

protocol InformationAlert {

	func showInformationAlert(
		title: String,
		message: String,
		dismissActionTitle: String,
		dismissAction: @escaping () -> Void)
}

extension InformationAlert where Self: UIViewController {

	func showInformationAlert(
		title: String,
		message: String,
		dismissActionTitle: String,
		dismissAction: @escaping () -> Void)
	{
		let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

		let dismissButton: UIAlertAction = UIAlertAction(title: dismissActionTitle, style: UIAlertAction.Style.default, handler: { (_: UIAlertAction) in
			dismissAction()
		})
		alert.addAction(dismissButton)

		self.present(alert, animated: true, completion: {
		})
	}

}
