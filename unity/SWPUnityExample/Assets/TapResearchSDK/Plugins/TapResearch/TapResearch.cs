using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TapResearch
{

	public static class Callback
	{
		public enum Name
		{
			OnTapResearchGrantBoostResponseReceived,
			OnTapResearchDidReceiveRewards, 
			OnTapResearchQQDataReceived,
			OnTapResearchSurveysRefreshed 
		}
		
		public static string ToString(this Callback.Name callbackName)
		{
			return callbackName switch 
			{
				Callback.Name.OnTapResearchGrantBoostResponseReceived => "OnTapResearchGrantBoostResponseReceived",
				Callback.Name.OnTapResearchDidReceiveRewards => "OnTapResearchDidReceiveRewards",
				Callback.Name.OnTapResearchQQDataReceived    => "OnTapResearchQQDataReceived",
				Callback.Name.OnTapResearchSurveysRefreshed  => "OnTapResearchSurveysRefreshed",
				_ => throw new ArgumentException("Invalid argument")
			};
		}	
	}
	
	public class TapResearchSDK : MonoBehaviour
	{
		private static TapResearchSDK _instance;
		private static AndroidJavaClass _androidBridge;
		
		// Keep in-sync with TapResearchSDKUnityBridge.mm file!
		public static string SDKVersion = "3.7.1--rc0";

		private static void InitializeInstance()
		{
			if (_instance == null)
			{
				_instance = FindObjectOfType(typeof(TapResearchSDK)) as TapResearchSDK;

				if (_instance == null)
				{
					_instance = new GameObject("TapResearchSDK").AddComponent<TapResearchSDK>();
					DontDestroyOnLoad(_instance);
				}
			}
		}
		
#region DELEGATE_DEFINITIONS
		public delegate void QQResponseDelegate(TRQQDataPayload payload);
		private static QQResponseDelegate _tapResearchQQResponseReceived;
		public static QQResponseDelegate TapResearchQQResponseReceived {
			get => _tapResearchQQResponseReceived;
			set {
				if (value != null) {
					_tapResearchQQResponseReceived = value;
					SetCallbackEnabled(Callback.Name.OnTapResearchQQDataReceived, true);
				}
				else {
					SetCallbackEnabled(Callback.Name.OnTapResearchQQDataReceived, false);
					_tapResearchQQResponseReceived = null;
				}			
			}
		}

		public delegate void RewardDelegate(TRReward[] rewards);
		private static RewardDelegate _tapResearchRewardReceived;
		public static RewardDelegate TapResearchRewardReceived {
			get => _tapResearchRewardReceived;
			set {
				if (value != null) {
					_tapResearchRewardReceived = value;
					SetCallbackEnabled(Callback.Name.OnTapResearchDidReceiveRewards, true);
				}
				else {
					SetCallbackEnabled(Callback.Name.OnTapResearchDidReceiveRewards, false);
					_tapResearchRewardReceived = null;
				}			
			}
		}

		public delegate void ErrorDelegate(TRError error);
		public static ErrorDelegate TapResearchDidError;

		public delegate void SdkReady();
		public static SdkReady TapResearchSdkReady;

		public delegate void TapResearchDidShow(string placementTag);
		public static TapResearchDidShow TapContentShown;

		public delegate void TapResearchDidDismiss(string placementTag);
		public static TapResearchDidDismiss TapContentDismissed;

		public delegate void TapResearchGrantBoostResponseReceived(TRGrantBoostResponse payload);
		public static TapResearchGrantBoostResponseReceived TapResearchGrantBoostResponse;

		public delegate void TapResearchSurveysRefreshDelegate(string placementTag);
		private static TapResearchSurveysRefreshDelegate _tapResearchSurveysRefreshed;
		public static TapResearchSurveysRefreshDelegate TapResearchSurveysRefreshed {
			get => _tapResearchSurveysRefreshed;
			set {
				if (value != null) {
					_tapResearchSurveysRefreshed = value;
					SetCallbackEnabled(Callback.Name.OnTapResearchSurveysRefreshed, true);
				}
				else {
					SetCallbackEnabled(Callback.Name.OnTapResearchSurveysRefreshed, false);
					_tapResearchSurveysRefreshed = null;
				}			
			}
		}

		#endregion

#region TAPRESEARCH

	public void OnTapResearchSurveysRefreshedForPlacement(string placementTag)
	{
		if (TapResearchSurveysRefreshed != null)
		{
			TapResearchSurveysRefreshed(placementTag);
		}
	}

	public void OnTapResearchContentShown(string placementTag)
	{
		if (TapContentShown != null)
		{
			TapContentShown(placementTag);
		}
	}

	public void OnTapResearchContentDismissed(string placementTag)
	{
		if (TapContentDismissed != null)
		{
			TapContentDismissed(placementTag);
		}
	}

	public void OnTapResearchQQDataReceived(string payload)
	{
		if (TapResearchQQResponseReceived != null) {
			//Debug.LogWarning("TapResearchQQResponseReceived!");

			var payloadObject = JsonUtility.FromJson<TRQQDataPayload>(payload);
			if (payloadObject != null) {
				TapResearchQQResponseReceived(payloadObject);
			}
			else {
			}
		}
		else {
			// This is not an SDK error, the developer did not set a handler for this in their own code.
			Debug.LogWarning("TapResearch: TapResearchQQResponseReceived Callback not set!");
		}
	}

	public void OnTapResearchDidReceiveRewards(string rewards)
	{
		if (TapResearchRewardReceived != null) {
			var rewardsObject = JsonUtility.FromJson<TRRewardList>("{\"rewards\":" + rewards + "}");
			if (rewardsObject != null) {
				TapResearchRewardReceived(rewardsObject.rewards);
			}
		}
	}

	public void OnTapResearchDidError(string error)
	{
		if (TapResearchDidError != null) {
			var errorObject = JsonUtility.FromJson<TRError>(error);
			TapResearchDidError(errorObject);
		}
	}

	public void OnTapResearchGrantBoostResponseReceived(string payload)
	{
		if (TapResearchGrantBoostResponse != null)
		{
			Debug.Log("TapResearchGrantBoostResponseReceived SET AND RECEIVED");
			var boostResponse = JsonUtility.FromJson<TRGrantBoostResponse>(payload);
			TapResearchGrantBoostResponse(boostResponse);
		}
		else
		{
			Debug.Log("TapResearchGrantBoostResponseReceived NOT SET STILL RECEIVED");
		}
	}
	
	public void OnTapResearchSdkReady()
	{
		//Debug.Log("TapResearch: The TapResearch SDK Ready received!");
		if (TapResearchSdkReady != null) {
			//Debug.Log("TapResearch: The TapResearch SDK Ready calling game's delegate");
			TapResearchSdkReady();
		}
	}

	[Serializable]
	private class TRRewardList
	{
		[SerializeField]
		public TRReward[] rewards;
	}

	[Serializable]
	private class TRSurveyList
	{
		[SerializeField]
		public TRSurvey[] surveys;
	}

#endregion

		void Awake()
		{
			name = "TapResearchSDK";
			DontDestroyOnLoad(transform.gameObject);
		}

#if UNITY_EDITOR || (!UNITY_IPHONE && !UNITY_ANDROID)

		static public void Configure(string apiToken, string userId)
		{
			Debug.LogWarning("TapResearch: The TapResearch SDK will not work in the Unity editor.");
		}
		static public void ConfigureWithUserAttributes(string apiToken, string userId, Dictionary<string, object> userAttributes, bool clearPreviousAttributes)
		{
			Debug.LogWarning("TapResearch: The TapResearch SDK will not work in the Unity editor.");
		}
		public static bool CanShowContent(string placementTag) { return false; }
		public static bool IsReady() { return false; }
		public static void ShowContentForPlacement(string placementTag) { }
		public static void ShowContentForPlacement(string placementTag, Dictionary<string, object> customParameters) { }
		public static void SendUserAttributes(Dictionary<string, object> userAttributes) { }
		public static void SendUserAttributes(Dictionary<string, object> userAttributes, bool clearPreviousAttributes) { }
		public static void UpdateCurrentUser(string userIdentifier) { }
		public static bool HasSurveys(string placementTag) { return false; }
		public static void GrantBoost(string boostTag) { }
		public static Nullable<TRPlacementDetails> GetPlacementDetails(string placementTag) { return new TRPlacementDetails(); }
		public static TRSurvey[] GetSurveysForPlacement(string placementTag) { return Array.Empty<TRSurvey>(); }
		public static void ShowSurveyForPlacement(string surveyId, string placementTag) { }
		public static void ShowSurveyForPlacement(string surveyId, string placementTag, Dictionary<string, object> customParameters) { }
		public static void SetCallbackEnabled(Callback.Name callbackName, bool enable) { }

#elif UNITY_IPHONE && !UNITY_EDITOR
	#region IPHONE

	public static void Configure (string apiToken, string userId)
	{
		InitializeInstance ();
		ConfigureIOS (apiToken, userId);
	}

	public static void ConfigureWithUserAttributes (string apiToken, string userId, Dictionary<string, object> userAttributes, bool clearPreviousAttributes)
	{
		InitializeInstance ();
		var jsonString = TRConvert.DictionaryToJsonString(userAttributes);
		ConfigureIOSWithUserAttributes (apiToken, userId, jsonString, clearPreviousAttributes);
	}

	public static void ShowContentForPlacement(String placementTag, Dictionary<string, object> customParameters)
	{
		var jsonString = TRConvert.DictionaryToJsonString(customParameters);

		ShowContentForPlacementWithCustomParameters(placementTag, jsonString);
	}

	public static void SendUserAttributes(Dictionary<string, object> userAttributes)
	{
		var jsonString = TRConvert.DictionaryToJsonString(userAttributes);

		SendUserAttributes(jsonString);
	}

	public static void SendUserAttributes(Dictionary<string, object> userAttributes, bool clearPreviousAttributes)
	{
		var jsonString = TRConvert.DictionaryToJsonString(userAttributes);

		SendUserAttributes(jsonString, clearPreviousAttributes);
	}

	public static void ShowSurveyForPlacement(string surveyId, string placementTag, Dictionary<string, object> customParameters)
	{
		var jsonString = TRConvert.DictionaryToJsonString(customParameters);

		ShowSurveyForPlacementWithCustomParameters(surveyId, placementTag, jsonString);
	}

	public static void GrantBoost(String boostTag)
	{
		GrantBoostWithBoostTag(boostTag);
	}

	public static Nullable<TRPlacementDetails> GetPlacementDetails(string placementTag)
	{
		string details = GetPlacementDetail(placementTag);
		if (details == "") {
			return null;
		}
		//Debug.Log("TapResearch.cs.GetPlacementDetails: " + details + "==END");
		var detailsObject = JsonUtility.FromJson<TRPlacementDetails>(details);
		//Debug.Log("TapResearch.cs.GetPlacementDetails: " + detailsObject.Name + " " + detailsObject.CurrencyName + "==END");
		return detailsObject;
	}

	public static TRSurvey[] GetSurveysForPlacement(string placementTag)
	{
		string surveys = GetSurveys(placementTag);
		//Debug.Log("GetSurveysForPlacement: " + surveys + "==END");
		var surveysObject = JsonUtility.FromJson<TRSurveyList>(surveys);
		//Debug.Log("GetSurveysForPlacement: " + surveysObject + "==END");
		if (surveysObject != null && surveysObject.surveys != null) {		
			return surveysObject.surveys;
		}
		else { 
			return Array.Empty<TRSurvey>();
		}
	}

	public static void SetCallbackEnabled(Callback.Name callbackName, bool enable)
	{
		Debug.Log("TapResearch: " + callbackName.ToString() + " is enabled? " + enable);
		SetCallbackEnabled(callbackName.ToString(), enable);
	}

	[DllImport ("__Internal")]
	extern public static void ConfigureIOS(string apiToken, string userId);
	[DllImport ("__Internal")]
	extern public static void ConfigureIOSWithUserAttributes(string apiToken, string userId, string userAttributes, bool clearPreviousAttributes);
	[DllImport ("__Internal")]
	extern public static void UpdateCurrentUser(string userId);
	[DllImport ("__Internal")]
	extern public static void ShowContentForPlacement(string placementTag);
	[DllImport ("__Internal")]
	extern public static void ShowContentForPlacementWithCustomParameters(string placementTag, string customParameters);
	[DllImport ("__Internal")]
	extern public static void SendUserAttributes(string userAttributes);
	[DllImport ("__Internal")]
	extern public static void SendUserAttributes(string userAttributes, bool clearPreviousAttributes);
	[DllImport ("__Internal")]
	extern public static bool IsReady();
	[DllImport ("__Internal")]
	extern public static bool CanShowContent(string placementTag);
	[DllImport ("__Internal")]
	extern public static bool HasSurveys(string placementTag);
	[DllImport ("__Internal")]
	extern public static bool GrantBoostWithBoostTag(string boostTag);
	[DllImport ("__Internal")]
	extern public static string GetPlacementDetail(string placementTag);
	[DllImport ("__Internal")]
	extern public static string GetSurveys(string placementTag);
	[DllImport ("__Internal")]
	extern public static void ShowSurveyForPlacement(string surveyId, string placementTag);
	[DllImport ("__Internal")]
	extern public static void ShowSurveyForPlacementWithCustomParameters(string surveyId, string placementTag, string customParameters);
	[DllImport ("__Internal")]
	extern public static void SetCallbackEnabled(string callbackName, bool enable);

	#endregion

#elif UNITY_ANDROID && !UNITY_EDITOR

		private static bool _pluginInitialized = false;
		private static AndroidJavaClass _unityPlayer;

		public static void Configure(string apiToken, string userId)
		{
			InitializeInstance();
			ConfigureAndroid(apiToken, userId);
		}

		public static void ConfigureWithUserAttributes(string apiToken, string userId, Dictionary<string, object> userAttributes, bool clearPreviousAttributes)
		{
			InitializeInstance();
			ConfigureAndroidWithUserAttributes(apiToken, userId, userAttributes, clearPreviousAttributes);
		}

		private static void InitializeAndroidPlugin()
		{
		    if (_pluginInitialized) return;
			// Check of existence of unitybridge and tapresearch libraries.
			_androidBridge = new AndroidJavaClass("com.tapresearch.ktunitybridge.TRUnityBridge");
			if (_androidBridge == null)
			{
				Debug.LogError("TapResearch: Can't create AndroidJavaClass!");
				return;
			}

			var localTapResearch = AndroidJNI.FindClass("com/tapresearch/tapsdk/TapResearch");

			if (localTapResearch != IntPtr.Zero)
			{
				AndroidJNI.DeleteLocalRef(localTapResearch);
			}
			else
			{
				Debug.LogError("TapResearch: Android config error. Make sure you've included both tapresearch.aar and unitybridge.aar in your Unity project's Assets/Plugins/Android folder.");
				return;
			}

			_unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
			_pluginInitialized = true;
		}

		private static void ConfigureAndroid(string apiToken, string userId)
		{
            InitializeAndroidPlugin();
            var javaActivity = _unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
            _androidBridge.CallStatic("initialize", apiToken, userId, javaActivity);
		}

		private static void ConfigureAndroidWithUserAttributes(string apiToken, string userId, Dictionary<string, object> userAttributes, bool clearPreviousAttributes)
		{
            InitializeAndroidPlugin();
            var javaActivity = _unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
            var jsonString = TRConvert.DictionaryToJsonString(userAttributes);
            _androidBridge.CallStatic("initializeWithUserAttributes", apiToken, userId, jsonString, clearPreviousAttributes, javaActivity);
		}

		public static void ShowContentForPlacement(string placementTag)
		{
			if (_pluginInitialized)
			{
				_androidBridge.CallStatic("showContent", placementTag);
			}
		}

		public static void ShowContentForPlacement(string placementTag, Dictionary<string, object> customParameters)
		{
			if (_pluginInitialized)
			{
				var jsonString = TRConvert.DictionaryToJsonString(customParameters);
				_androidBridge.CallStatic("showContent", placementTag, jsonString);
			}
		}

		public static void SendUserAttributes(Dictionary<string, object> userAttributes)
		{
			if (_pluginInitialized)
			{
				var jsonString = TRConvert.DictionaryToJsonString(userAttributes);
				_androidBridge.CallStatic("sendUserAttributes", jsonString);
			}
		}

		public static void SendUserAttributes(Dictionary<string, object> userAttributes, bool clearPreviousAttributes)
		{
			if (_pluginInitialized)
			{
				var jsonString = TRConvert.DictionaryToJsonString(userAttributes);
				_androidBridge.CallStatic("sendUserAttributes", jsonString, clearPreviousAttributes);
			}
		}

		public static void UpdateCurrentUser(String userIdentifier)
		{
			if (_pluginInitialized)
			{
				_androidBridge.CallStatic("updateCurrentUser", userIdentifier);
			}
		}
		
		public static bool CanShowContent(string placementTag)
		{
			var _canShowContent = false;
			if (_pluginInitialized)
			{
				_canShowContent = _androidBridge.CallStatic<bool>("canShowContent", placementTag);
			}
			return _canShowContent;
		}

		public static bool IsReady()
		{
			var _isReady = false;
			if (_pluginInitialized)
			{
				_isReady = _androidBridge.CallStatic<bool>("isReady");	
			}
			return _isReady;
		}

		public static bool HasSurveys(string placementTag)
		{
			var _hasSurveys = false;
			if (_pluginInitialized)
			{
				_hasSurveys = _androidBridge.CallStatic<bool>("hasSurveysForPlacement", placementTag);
			}
			return _hasSurveys;
		}

		public static Nullable<TRPlacementDetails> GetPlacementDetails(string placementTag)
		{
			if (_pluginInitialized)
			{
			    try {
                    var details = _androidBridge.CallStatic<string>("getPlacementDetails", placementTag);
                    if (details == null || details == "") {
                        return null;
                    }
                    var detailsObject = JsonUtility.FromJson<TRPlacementDetails>(details);
                    return detailsObject;
				} catch (System.Exception ex) {
                    // Catch general exceptions
                    Debug.LogError("Caught a general exception: " + ex.Message);
                }
			}
			return null;
		}

		public static TRSurvey[] GetSurveysForPlacement(string placementTag)
		{
			if (_pluginInitialized)
			{
				var surveys = _androidBridge.CallStatic<string>("getSurveysForPlacement", placementTag);
				var surveysObject = JsonUtility.FromJson<TRSurveyList>("{\"surveys\":" + surveys + "}");
				return surveysObject.surveys;
			}
			return null;	
		}

		public static void ShowSurveyForPlacement(string surveyId, string placementTag)
		{
			if (_pluginInitialized)
			{
				_androidBridge.CallStatic("showSurveyForPlacement", placementTag, surveyId);
			}
		}

		public static void ShowSurveyForPlacement(string surveyId, string placementTag, Dictionary<string, object> customParameters)
		{
			if (_pluginInitialized)
			{
				var jsonString = TRConvert.DictionaryToJsonString(customParameters);
				_androidBridge.CallStatic("showSurveyForPlacement", placementTag, surveyId, jsonString);
			}
		}

		public static void SetCallbackEnabled(Callback.Name callbackName, bool enable)
		{
            InitializeAndroidPlugin();
			_androidBridge.CallStatic("setCallbackEnabled", callbackName.ToString(), enable);
		}

		public static void GrantBoost(string boostTag)
		{
			if (_pluginInitialized)
			{
				_androidBridge.CallStatic("grantBoost", boostTag);
			}
		}
#endif

	}
}
