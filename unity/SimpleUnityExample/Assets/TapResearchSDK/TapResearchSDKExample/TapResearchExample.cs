using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapResearchExample : MonoBehaviour
{
    public TRScreenFader screenFader;
    public TROrientationChanger orientationChanger;
    public TRWaiter waiter;
    public string surveysPlacementTag;
    public GameObject surveysButton;

    #if UNITY_ANDROID
    private static string tapAPIToken = "4aa77f4dc27e761d577d1189433cc62f"; // Public Test Android, replace with your own API token
    #elif UNITY_IPHONE
    private static string tapAPIToken = "100e9133abc21471c8cd373587e07515";  // Public Test iOS, replace with your own API token
    #else 
    private static string tapAPIToken = "NotAvailebleInEditor";  // Public Test iOS, replace with your own API token
    #endif
    private static string tapPlayerUserId = "some-test-user-12";
    private static string placementTag = "earn-center";
    private static string boostTag = "boost"; // Replace this with your own boost tag.
    
    void Awake()
    {
        Screen.orientation = ScreenOrientation.Portrait;//.LandscapeLeft;
        Debug.Log("TapResearchExample: About to initialize Tap SDK");
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        // TapResearchSDK.TapResearchQQResponseReceived = TapQQResponseReceived;
        // TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        // TapResearchSDK.TapResearchGrantBoostResponse = TapResearchGrantBoostResponse;
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
        orientationChanger.SetPortrait(OnOrientationChangedToLandscapeLeft);//.SetLandscapeLeft(OnOrientationChangedToLandscapeLeft);
     }

    public void TapSdkReady()
    {
		if (TapResearchSDK.IsReady()) // There is no need for this here, it is just for illustration
        {
            TRPlacementDetails? details = TapResearchSDK.GetPlacementDetails("earn-center");
            if (details != null)
            {
                Debug.Log("TapResearchExample: Placement Details Found: " + details?.Name + " " + details?.CurrencyName);
            }
            else
            {
                Debug.Log("TapResearchExample: NO Placement Details Found!");
            }
            
            // TapResearchSDK.GrantBoost("bo00ost-3x-1d");
            
            TapResearchSDK.TapResearchQQResponseReceived = TapQQResponseReceived;
            TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;

            Debug.Log("TapResearchExample: TapResearchSDK ready, going to send user attributes...");

            Dictionary<string, object> userAttributes = new Dictionary<string, object>();
            userAttributes["some_string"] = "a string value";
            userAttributes["some_number"] = "12";
            userAttributes["another_number"] = 12;
            userAttributes["boolean"] = "true";
            System.DateTime now = System.DateTime.UtcNow;
            string iso8601String = now.ToString("o");
            userAttributes["iso8601_date"] = iso8601String;
            userAttributes.Add("another_string", "it's another string!");
    
            TapResearchSDK.SendUserAttributes(userAttributes, true);

            if (TapResearchSDK.HasSurveys(placementTag)) {
                surveysButton.SetActive(true);
            }
            else {
                surveysButton.SetActive(false);
            }
        }
    }

    private void TapQQResponseReceived(TRQQDataPayload payload) {
        Debug.Log("TapResearchExample: TRQQDataPayload received! placement: " + payload.PlacementTag + " userIdentifier: " + payload.UserIdentifier);
    }

    private void TapResearchRewardReceived(TRReward[] rewards) {
        Debug.Log("TapResearchExample: TRReward received!");

        foreach (TRReward reward in rewards)
        {
            Debug.Log("TapResearchExample: Tap Rewards: You've earned " + reward.RewardAmount + " [" + reward.CurrencyName + "] TransactionIdentifier: " + reward.TransactionIdentifier + " PayoutEvent: ["+reward.PayoutEvent+"]");
        }
    }
    
    private void TapResearchDidError(TRError error) {
        Debug.Log("TapResearchExample: TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + "");
    }

    // private void TapResearchGrantBoostResponse(TRGrantBoostResponse response)
    // {
    //     Debug.Log("TapResearchExample: TRGrantBoostResponseReceived " + response.BoostTag);   
    // }
    
    // END Callbacks

    public void showSurveyContent()
    {
        if (TapResearchSDK.CanShowContent(placementTag)) 
        {
            Debug.Log("TapResearchExample: TapResearchSDK showSurveyContent() fading to black");
            //Debug.Log("TapResearchExample: TapResearchSDK showSurveyContent() showing content");
            screenFader.FadeToBlack(OnFadeToBlackComplete);
        }
        else {
            Debug.Log("TapResearchExample: TapResearchSDK showSurveyContent() content not available");
        }
    }
    
    public void showSurveyContentWithParameters()
    {
        if (TapResearchSDK.CanShowContent(placementTag)) //CustomParam Placement
        {
            Dictionary<string, object> customParameters = new Dictionary<string,object>(); //Parameters
            customParameters["player_attribute"] = "my-vip";
            customParameters["data_value"] = "integer";
            customParameters["another_number"] = 12;   
            customParameters.Add("another_string", "it's another string!");
            
            TapResearchSDK.ShowContentForPlacement(placementTag, customParameters);
        }
    }

    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample: TapResearchSDK OnButtonClick() attempting to show content");
        showSurveyContent();
    }

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
        TapResearchSDK.ShowContentForPlacement(placementTag); 
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
