using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapExample : MonoBehaviour
{
    private static string tapAPIToken; 
    private static string tapPlayerUserId = "public-demo-test-user";
    private static string placementTag = "home-screen"
    
    void Awake()
    { 
        if UNITY_ANDROID
            tapAPIToken = "856f987d813389d1243bea2e4731a0fb";  // Public Test Android, replace with your own API token
        #elif UNITY_IPHONE
            tapAPIToken = "0b5dcbae8151c1b82d69697dce004bf2";  // Public Test iOS, replace with your own API token
        #endif
            
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardsReceived;
        TapResearchSDK.TapResearchDidError = TapResearchDidError;
        TapResearchSDK.TapResearchSdkReady = TapSdkReady;

        TapResearchSDK.Configure(tapAPIToken, tapPlayerUserId);
    }

    // START Callbacks
    
    public void TapContentShown()
    {
        Debug.Log("Survey Content Opened");
    }

    public void TapContentDismissed()
    {
        Debug.Log("Survey Content Dismissed");
    }

    public void TapSdkReady()
    {
        Debug.Log("TapResearchSDK ready, going to send user attributes");

        Dictionary<string, object> userAttributes = new Dictionary<string, object>();
        userAttributes["some_string"] = "a string value";
        userAttributes["some_number"] = "12";
        userAttributes["another_number"] = 12;
        userAttributes["boolean"] = "true";
        DateTime now = DateTime.UtcNow;
        string iso8601String = now.ToString("o");
        userAttributes["iso8601_date"] = iso8601String;
        userAttributes.Add("another_string", "it's another string!");

        TapResearchSDK.SendUserAttributes(userAttributes);
    }

    private void TapResearchRewardsReceived(TRReward[] rewards) {
        foreach (TRReward reward in rewards)
        {
            Debug.Log("Tap Rewards: You've earned " + reward.RewardAmount + " " + reward.CurrencyName + ". " + reward.TransactionIdentifier);
        }
    }
    
    private void TapResearchDidError(TRError error) {
        Debug.Log(("TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + ""));
    }

    // END Callbacks

    public void showSurveyContent()
    {
        if (TapResearchSDK.CanShowContentForPlacement(placementTag)) 
        {
            TapResearchSDK.ShowContentForPlacement(placementTag); 
        }
    }
    
    public void showSurveyContentWithParameters()
    {
        if (TapResearchSDK.CanShowContentForPlacement(placementTag)) //CustomParam Placement
        {
            Dictionary<string, string> customParameters = new Dictionary<string,string>(); //Parameters
            customParameters["player_attribute"] = "my-vip";
            customParameters["data_value"] = "integer";
            customParameters["another_number"] = 12;   
            customParameters.Add("another_string", "it's another string!");
              
            TapResearchSDK.ShowContentForPlacement(placementTag, customParameters);
        }
    }
}
