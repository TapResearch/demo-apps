//
//  TapResearchSDKUnityNative.swift
//
//
//  Created by Jeroen Verbeek on 2/22/23.
//

import Foundation
import TapResearchSDK

// MARK: - TapResearchSDKUnityNative

@objc public class TapResearchSDKUnityNativeInterface: TapResearchSDKUnityCaller {
    @objc public static let shared: TapResearchSDKUnityNativeInterface = .init()

    let sdkDelegate: TapResearchSDKUnitySDKDelegate = .init()
    let contentDelegate: TapResearchSDKUnityContentDelegate = .init()
    let tapRewardDelegates: TapResearchRewardDelegates = .init()
    let tapQQDataDelegates: TapResearchQuickQuestionDelegates = .init()
    let tapSurveyDelegate: TapResearchSDKSurveysDelegates = .init()
	let tapGrantBoostDelegate: TapResearchGrantBoostResponseDelegates = .init()

    // MARK: - Interfaces for Unity/C#

    /// ---------------------------------------------------------------------------------------------
    @objc public func initialize(apiToken: String, userIdentifier: String) {
        // print("BRIDGE: \(#function):\nBRIDGE+ apiToken: \(apiToken),\nBRIDGE+ userIdentifier: \(userIdentifier)")

		TapResearch.initialize(withAPIToken: apiToken, userIdentifier: userIdentifier, sdkDelegate: sdkDelegate) { (error: NSError?) in
            if let error = error {
                self.sdkDelegate.onTapResearchDidError(error)
            }
        }
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func initialize(apiToken: String, userIdentifier: String, userAttributes: [String: Any], clearPreviousAttributes: Bool) {
        // print("BRIDGE: \(#function):\nBRIDGE+ apiToken: \(apiToken),\nBRIDGE+ userIdentifier: \(userIdentifier),\nBRIDGE+ userAttributes: \(String(describing: userAttributes)),\n        clearPreviousAttributes: \(clearPreviousAttributes)")

        TapResearch.initialize(withAPIToken: apiToken,
                               userIdentifier: userIdentifier,
                               userAttributes: userAttributes,
                               clearPreviousAttributes: clearPreviousAttributes,
                               sdkDelegate: sdkDelegate)
        { (error: NSError?) in
            if let error = error {
                self.sdkDelegate.onTapResearchDidError(error)
            }
        }
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func setUserIdentifier(_ userIdentifier: String) {
        // print("BRIDGE: \(#function):\nBRIDGE+ userIdentifier: \(userIdentifier)")

        TapResearch.setUserIdentifier(userIdentifier) { (error: NSError?) in
            if let error = error {
                self.sdkDelegate.onTapResearchDidError(error)
            }
        }
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func isReady() -> Bool {
        let ready: Bool = TapResearch.isReady()
        // print("BRIDGE: \(#function):\nBRIDGE+ isReady = \(ready ? "true" : "false")")
        return ready
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func canShowPlacement(placementTag: String) -> Bool {
        let canShow: Bool = TapResearch.canShowContent(forPlacement: placementTag)
        // print("BRIDGE: \(#function):\nBRIDGE+ placementTag: \(placementTag) = \(canShow ? "true" : "false")")
        return canShow
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func showPlacement(placementTag: String) {
        // print("BRIDGE: \(#function):\nBRIDGE+ placementTag: \(placementTag)")

        TapResearch.showContent(forPlacement: placementTag, delegate: contentDelegate) { (error: NSError?) in
            if let error = error {
                self.sdkDelegate.onTapResearchDidError(error)
            }
        }
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func showPlacement(placementTag: String, customParameters: [String: Any]) {
        // print("BRIDGE: \(#function):\nBRIDGE+ placementTag: \(placementTag)\nBRIDGE+ customParameters: \(String(describing: customParameters))")

        TapResearch.showContent(forPlacement: placementTag, delegate: contentDelegate, customParameters: customParameters) { (error: NSError?) in
            if let error = error {
                self.sdkDelegate.onTapResearchDidError(error)
            }
        }
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func sendUserAttributes(_ userAttributes: [String: Any]) {
        // print("BRIDGE: \(#function):\nBRIDGE+ UserAttributes: \(String(describing: userAttributes))")

        let error = TapResearch.sendUserAttributes(attributes: userAttributes)
        if let error = error {
            sdkDelegate.onTapResearchDidError(error)
        }
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func sendUserAttributes(_ userAttributes: [String: Any], clearPreviousAttributes: Bool) {
        // print("BRIDGE: \(#function):\nBRIDGE+ UserAttributes: \(String(describing: userAttributes)),\nBRIDGE+ clearPreviousAttributes: \(clearPreviousAttributes)")

        let error = TapResearch.sendUserAttributes(attributes: userAttributes, clearPreviousAttributes: clearPreviousAttributes)
        if let error = error {
            sdkDelegate.onTapResearchDidError(error)
        }
    }

    // MARK: - Callback enabler

    /// ---------------------------------------------------------------------------------------------
    @objc public func setCallbackEnabled(_ callbackName: String, enabled: Bool) {
        // print("BRIDGE: \(#function):\nBRIDGE+ callbackName: \(callbackName), enabled: \(enabled)")

        switch callbackName {
        case "OnTapResearchDidReceiveRewards":
            TapResearch.setRewardDelegate(enabled ? tapRewardDelegates : nil)
        case "OnTapResearchQQDataReceived":
            TapResearch.setQuickQuestionDelegate(enabled ? tapQQDataDelegates : nil)
        case "OnTapResearchSurveysRefreshed":
            TapResearch.setSurveysDelegate(enabled ? tapSurveyDelegate : nil)
        default:
            break
        }
    }

	//MARK: - Placement details

	/// ---------------------------------------------------------------------------------------------
    @objc public func getPlacementDetails(placement: String) -> String! {
		//print("BRIDGE: \(#function):\nBRIDGE+ placementTag: \(placement)")

		let details: TRPlacementDetails? = TapResearch.getPlacementDetails(placement) { (_: NSError?) in }

		if let details: TRPlacementDetails = details {
			let encoder = JSONEncoder()
			encoder.keyEncodingStrategy = .useDefaultKeys
			if let jsonData: Data = try? encoder.encode(details) {
				if let jsonString = String(data: jsonData, encoding: String.Encoding.ascii) {
					return jsonString
				}
			}
		}
		return ""
	}
	
	//MARK: - Grant Boost

	/// ---------------------------------------------------------------------------------------------
	@objc public func grantBoost(boostTag: String) {
		print("BRIDGE: \(#function):\nBRIDGE+ boostTag: \(boostTag)")

		TapResearch.grantBoost(boostTag, delegate: tapGrantBoostDelegate) { (error: NSError?) in
			if let error {
				self.sdkDelegate.onTapResearchDidError(error)
			}
		}
	}

	// MARK: - Surveys

    /// ---------------------------------------------------------------------------------------------
    @objc public func getSurveys(placement: String) -> String {
        // print("BRIDGE: \(#function):\nBRIDGE+ placementTag: \(placement)")
        let surveys: [TRSurvey] = TapResearch.getSurveys(for: placement)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        if let jsonData: Data = try? encoder.encode(surveys) {
            if let jsonString = String(data: jsonData, encoding: String.Encoding.ascii) {
				return "{ \"surveys\" : " + jsonString + "}"
            }
        }

        return ""
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func hasSurveys(placementTag: String) -> Bool {
        let flag: Bool = TapResearch.hasSurveys(for: placementTag)
        return flag
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func showSurvey(surveyId: String, placement: String) {
        // print("BRIDGE: \(#function):\nBRIDGE+ surveyId: \(surveyId)\nBRIDGE+ placementTag: \(placement)")

        TapResearch.showSurvey(surveyId: surveyId, placementTag: placement, delegate: contentDelegate) { (error: NSError?) in
            if let error = error {
                self.sdkDelegate.onTapResearchDidError(error)
            }
        }
    }

    /// ---------------------------------------------------------------------------------------------
    @objc public func showSurvey(surveyId: String, placement: String, customParameters: [String: Any]) {
        // print("BRIDGE: \(#function):\nBRIDGE+ surveyId: \(surveyId)\nBRIDGE+ placementTag: \(placement)\nBRIDGE+ customParameters: \(String(describing: customParameters))")

        TapResearch.showSurvey(surveyId: surveyId, placementTag: placement, delegate: contentDelegate, customParameters: customParameters) { (error: NSError?) in
            if let error = error {
                self.sdkDelegate.onTapResearchDidError(error)
            }
        }
    }
}

// MARK: - TapResearchSDKUnityCaller

public class TapResearchSDKUnityCaller: NSObject {
    let sdkUnitySendMessageTarget: String = "TapResearchSDK"
    let unity: UnityFramework = .init()

    /// ---------------------------------------------------------------------------------------------
    func callUnityFunction(functionName: String, message: String) {
        unity.sendMessageToGO(withName: sdkUnitySendMessageTarget, functionName: (functionName as NSString).cString(using: NSASCIIStringEncoding), message: (message as NSString).cString(using: NSASCIIStringEncoding))
    }
}

// MARK: - TapResearchSurveysDelegates

class TapResearchSDKSurveysDelegates: TapResearchSDKUnityCaller, TapResearchSurveysDelegate {
    /// ---------------------------------------------------------------------------------------------
    @objc func onTapResearchSurveysRefreshed(forPlacement placement: String) {
        // print("BRIDGE DELEGATE: \(#function)")

        callUnityFunction(functionName: "OnTapResearchSurveysRefreshedForPlacement", message: placement)
    }
}

// MARK: - TapResearchSDKDelegate

class TapResearchSDKUnitySDKDelegate: TapResearchSDKUnityCaller, TapResearchSDKDelegate {
    // No longer implementing callbacks for rewards or qq data, they are now in individual delegate classes below.
    // These are now enabled and disabled when needed.

    /// ---------------------------------------------------------------------------------------------
    @objc func onTapResearchDidError(_ error: NSError) {
        // print("BRIDGE DELEGATE: \(#function):\nBRIDGE+ error: \(String(describing: error))")

        let jsonString = "{ \"errorCode\" : \(error.code), \"errorDescription\" : \"\(error.localizedDescription)\" }"
        callUnityFunction(functionName: "OnTapResearchDidError", message: jsonString)
    }

    /// ---------------------------------------------------------------------------------------------
    @objc func onTapResearchSdkReady() {
        // print("BRIDGE DELEGATE: \(#function)")

        callUnityFunction(functionName: "OnTapResearchSdkReady", message: "")
    }
}

// MARK: - TapResearchContentDelegate

class TapResearchSDKUnityContentDelegate: TapResearchSDKUnityCaller, TapResearchContentDelegate {
    /// ---------------------------------------------------------------------------------------------
    @objc func onTapResearchContentShown(forPlacement placement: String) {
        // print("BRIDGE DELEGATE: \(#function)")

        callUnityFunction(functionName: "OnTapResearchContentShown", message: placement)
    }

    /// ---------------------------------------------------------------------------------------------
    @objc func onTapResearchContentDismissed(forPlacement placement: String) {
        // print("BRIDGE DELEGATE: \(#function)")

        callUnityFunction(functionName: "OnTapResearchContentDismissed", message: placement)
    }
}

// MARK: - TapResearchRewardDelegates

class TapResearchRewardDelegates: TapResearchSDKUnityCaller, TapResearchRewardDelegate {
    /// ---------------------------------------------------------------------------------------------
    @objc func onTapResearchDidReceiveRewards(_ rewards: [TRReward]) {
        // print("BRIDGE DELEGATE: \(#function)")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        if let jsonData: Data = try? encoder.encode(rewards) {
            if let jsonString = String(data: jsonData, encoding: String.Encoding.ascii) {
                callUnityFunction(functionName: "OnTapResearchDidReceiveRewards", message: jsonString)
            }
        }
    }
}

// MARK: - TapResearchQuickQuestionDelegates

class TapResearchQuickQuestionDelegates: TapResearchSDKUnityCaller, TapResearchQuickQuestionDelegate {
    /// ---------------------------------------------------------------------------------------------
    @objc func onTapResearchQuickQuestionResponse(_ qqPayload: TRQQDataPayload) {
        // print("BRIDGE DELEGATE: \(#function)")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        if let jsonData: Data = try? encoder.encode(qqPayload) {
            if let jsonString = String(data: jsonData, encoding: String.Encoding.ascii) {
                callUnityFunction(functionName: "OnTapResearchQQDataReceived", message: jsonString)
            }
        }
    }
}

//MARK: - TapResearchGrantBoostResponseDelegate

class TapResearchGrantBoostResponseDelegates: TapResearchSDKUnityCaller, TapResearchGrantBoostResponseDelegate {
	/// ---------------------------------------------------------------------------------------------
	func onTapResearchGrantBoostResponse(_ response: TapResearchSDK.TRGrantBoostResponse) {
		print("BRIDGE DELEGATE: \(#function): boostTag=\(response.boostTag), success=\(response.success), error.code=\(response.error?.code), error.localizedDescription=\(response.error?.localizedDescription)")

		let encoder: JSONEncoder = JSONEncoder()
		encoder.keyEncodingStrategy = .useDefaultKeys
		if let data: Data = try? encoder.encode(response) {
			if let jsonString = String(data: data, encoding: String.Encoding.utf8) {
				callUnityFunction(functionName: "OnTapResearchGrantBoostResponseReceived", message: jsonString)
			}
		}
	}
}
