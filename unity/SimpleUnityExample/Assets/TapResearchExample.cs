using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapResearchExample : MonoBehaviour
{
    private static string tapAPIToken = "fb28e5e0572876db0790ecaf6c588598";
    private static string tapPlayerUserId = "public-demo-test-user";
    private static string placementTag = "earn-center";
    
    void Awake()
    {

        Debug.Log("TapResearchExample: About to initialize Tap SDK");
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        TapResearchSDK.TapResearchQQResponseReceived = TapQQResponseReceived;
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        TapResearchSDK.TapResearchDidError = TapResearchDidError;
        TapResearchSDK.TapResearchSdkReady =  TapSdkReady;

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
    }

    public void TapSdkReady()
    {
        Debug.Log("TapResearchExample: TapResearchSDK ready, going to send user attributes");

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
        Debug.Log(("TapResearchExample: TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + ""));
    }

    // END Callbacks

    public void showSurveyContent()
    {
        if (TapResearchSDK.CanShowContent(placementTag)) 
        {
            Debug.Log("TapResearchExample: TapResearchSDK showSurveyContent() showing content");
            TapResearchSDK.ShowContentForPlacement(placementTag); 
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

}