using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapExample : MonoBehaviour
{
    private static string tapAPIToken = "0b5dcbae8151c1b82d69697dce004bf2"; 
    private static string tapPlayerUserId = "public-demo-test-user";
    private static string placementTag = "home-screen";
    
    void Awake()
    {         
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
        Debug.Log("Survey Content Opened");
    }

    public void TapContentDismissed(string placementTag)
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
        System.DateTime now = System.DateTime.UtcNow;
        string iso8601String = now.ToString("o");
        userAttributes["iso8601_date"] = iso8601String;
        userAttributes.Add("another_string", "it's another string!");

        TapResearchSDK.SendUserAttributes(userAttributes);
    }

    private void TapQQResponseReceived(TRQQDataPayload payload) {
        Debug.Log("TRQQDataPayload received!");
    }


    private void TapResearchRewardReceived(TRReward[] rewards) {
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
        Debug.Log("TapResearchSDK showSurveyContent() checking if content can show");
        if (TapResearchSDK.CanShowContent(placementTag)) 
        {
            Debug.Log("TapResearchSDK showSurveyContent() showing content");
            TapResearchSDK.ShowContentForPlacement(placementTag); 
        }
        else {
            Debug.Log("TapResearchSDK showSurveyContent() content can't show");
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
        Debug.Log("TapResearchSDK OnButtonClick() attempting to show content");
        showSurveyContent();
    }

}
