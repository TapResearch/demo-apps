using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapResearchExample : MonoBehaviour
{
    public TRScreenFader screenFader;
    public TROrientationChanger orientationChanger;
    public TRWaiter waiter;
    public GameObject showSurveyWallPreviewButton;
    public GameObject wallButton;
    public GameObject boostButton;
    public GameObject bannerButton;
    public GameObject qqButton;

    public string tapAPIToken;
    public string tapQQPlacement = "";
    public string tapWallPlacement = "earn-center";
    public string tapBannerPlacement = "banner";
    public string tapInterstitialPlacement = "";
    public string tapSurveyWallPreviewPlacement = "earn-center";
    public string tapBoostTag = "boost-3x-1d";
    public static string tapPlayerUserId = "public-test-user-2026-02-18";
                
    void Awake()
    {
        if (tapAPIToken == null || tapAPIToken == "")
        {
            #if UNITY_ANDROID
            tapAPIToken = "YOUR_ANDROID_API_TOKEN"; // Public Test Android, replace with your own API token
            #elif UNITY_IPHONE
            tapAPIToken = "100e9133abc21471c8cd373587e07515";  // Public Test iOS, replace with your own API token
            #else 
            tapAPIToken = "NotAvailableInEditor";
            #endif
        }
    
        Screen.orientation = ScreenOrientation.Portrait;//.LandscapeLeft;
        Debug.Log("TapResearchExample: About to initialize Tap SDK");
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        TapResearchSDK.TapResearchQQResponseReceived = TapQQResponseReceived;
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        TapResearchSDK.TapResearchDidError = TapResearchDidError;
        TapResearchSDK.TapResearchSdkReady = TapSdkReady;
        screenFader.SetAlpha(0.0f);
        TapResearchSDK.Configure(tapAPIToken, tapPlayerUserId);
    }

    // START Callbacks
    
    public void TapContentShown(string placementTag)
    {
        Debug.Log("TapResearchExample: Survey Content Opened");
    }

    public void TapContentDismissed(string placementTag)
    {
        Debug.Log("TapResearchExample: Survey Content Dismissed");
        if (placementTag == tapWallPlacement)
        {
            orientationChanger.SetPortrait(OnOrientationChangedToLandscapeLeft); //.SetLandscapeLeft(OnOrientationChangedToLandscapeLeft);
        }
    }

    public void TapSdkReady()
    {
        Debug.Log("TapResearchExample: TapResearchSDK ready, going to send user attributes...");
        
        // If you want to test user attributes:
        // Dictionary<string, object> userAttributes = new Dictionary<string, object>();
        // userAttributes["some_string"] = "a string value";
        // userAttributes["some_number"] = "12";
        // userAttributes["another_number"] = 12;
        // userAttributes["boolean"] = "true";
        // System.DateTime now = System.DateTime.UtcNow;
        // string iso8601String = now.ToString("o");
        // userAttributes["iso8601_date"] = iso8601String;
        // userAttributes.Add("another_string", "it's another string!");
        // TapResearchSDK.SendUserAttributes(userAttributes, true);
        
        wallButton.SetActive(true);
        boostButton.SetActive(true);
        bannerButton.SetActive(true);
        qqButton.SetActive(true);

        if (TapResearchSDK.HasSurveys(tapWallPlacement)) {
            showSurveyWallPreviewButton.SetActive(true);
        }
        else {
            showSurveyWallPreviewButton.SetActive(false);
        }
    }

    private void TapQQResponseReceived(TRQQDataPayload payload) {
        Debug.Log("TapResearchExample: TRQQDataPayload received! placement: " + payload.PlacementTag + " userIdentifier: " + payload.UserIdentifier);
    }

    private void TapResearchRewardReceived(TRReward[] rewards) {

        foreach (TRReward reward in rewards)
        {
            Debug.Log("TapResearchExample: Tap Rewards: You've earned " + reward.RewardAmount + " " + reward.CurrencyName + ". " + reward.TransactionIdentifier);
        }
    }
    
    private void TapResearchDidError(TRError error) {
        Debug.Log("TapResearchExample: TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + "");
    }

    // END Callbacks

    public void showWallContent()
    {
        if (TapResearchSDK.CanShowContent(tapWallPlacement)) 
        {
            Debug.Log("TapResearchExample: TapResearchSDK showSurveyContent() fading to black");
            screenFader.FadeToBlack(OnFadeToBlackComplete);
        }
        else {
            Debug.Log("TapResearchExample: TapResearchSDK showSurveyContent() content not available");
        }
    }
    
    public void showWallContentWithParameters()
    {
        if (TapResearchSDK.CanShowContent(tapWallPlacement)) //CustomParam Placement
        {
            Dictionary<string, object> customParameters = new Dictionary<string,object>(); //Parameters
            customParameters["player_attribute"] = "my-vip";
            customParameters["data_value"] = "integer";
            customParameters["another_number"] = 12;   
            customParameters.Add("another_string", "it's another string!");
            TapResearchSDK.ShowContentForPlacement(tapWallPlacement, customParameters);
        }
    }

    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample: TapResearchSDK OnButtonClick() attempting to show content");
        showWallContent();
        // If you want to test custom parameters use showWallContentWithParameters().
    }

    public void OnBoostButtonClick()
    {
        Debug.Log("TapResearchExample: TapResearchSDK OnBoostButtonClick() attempting to apply boost");
        if (tapBoostTag.Length > 0)
        {
            TapResearchSDK.GrantBoost(tapBoostTag);
        }
    }
    
    public void OnBannerButtonClick()
    {
        Debug.Log("TapResearchExample: TapResearchSDK OnBannerButtonClick() attempting to show banner");
        if (TapResearchSDK.CanShowContent(tapBannerPlacement))
        {
            TapResearchSDK.ShowContentForPlacement(tapBannerPlacement);
        }
    }
    
    public void OnQQButtonClick()
    {
        Debug.Log("TapResearchExample: TapResearchSDK OnButtonClick() attempting to show quick question");
        if (TapResearchSDK.CanShowContent(tapQQPlacement))
        {
            TapResearchSDK.ShowContentForPlacement(tapQQPlacement);
        }    }
    
    // Fader and orientation callbacks

    private void OnFadeToBlackComplete()
    {
        Debug.Log("Unity C# TestButton: Fade to black complete!");
        orientationChanger.SetAutoRotate(OnOrientationChangedForSurveys);        
        //If you don't want to auto-rotate you can force it into portrait for example: orientationChanger.SetPortrait(OnOrientationChangedForSurveys);
    }

    private void OnOrientationChangedForSurveys()
    {
        Debug.Log("Unity C# TestButton: OnOrientationChangedForSurveys complete, showing survey modal!!");
        TapResearchSDK.ShowContentForPlacement(tapWallPlacement); 
    }
        
    private void OnOrientationChangedToLandscapeLeft()
    {
        Debug.Log("Unity C# TestButton: OnOrientationChangedToLandscapeLeft complete, fading from black!!");
        waiter.Wait(1.0f, () => {
            // Debug.Log("Unity C# TestButton: Waiter done"); 
            screenFader.FadeFromBlack(() => { Debug.Log("Unity C# TestButton: fade from black complete!"); });
        });
    }

}
