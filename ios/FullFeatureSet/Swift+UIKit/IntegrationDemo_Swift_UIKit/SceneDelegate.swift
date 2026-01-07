//
//  SceneDelegate.swift
//  IntegrationDemo_Swift_UIKit
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import UIKit
import TapResearchSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate, LogPrint {

	var window: UIWindow?

	// Token for example is in TapResearchToken.swift
	let userIdentifier: String = "public-demo-test-user" // Replace with your own app's player user id

	let tapDelegates: TapResearchDelegates = TapResearchDelegates()

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let _ = (scene as? UIWindowScene) else { return }

		// Initialize TapResearch
		let dict: [String:Any] = ["some_string" : "a string value", "some_number" : 12]
		TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userIdentifier, userAttributes: dict, clearPreviousAttributes: true, sdkDelegate:tapDelegates) { (error: Error?) in
			if let error = error {
				self.logPrint(error.localizedDescription)
			}
			else {
				self.logPrint("Intialized - waiting to be ready")
			}
		}

		// Initialize TapResearchSDK without passing user attributes:
		//TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userIdentifier, sdkDelegate: tapDelegates) { (error: NSError?) in
		//	if let e = error {
		//		print(e.localizedDescription as Any)
		//	}
		//}
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
	
}
