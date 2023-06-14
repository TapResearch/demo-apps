using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapExample : MonoBehaviour
{
    private static string testToken = "YOUR_API_TOKEN"; 
    private static string testUserId = "Nascar";
    
    void Awake()
    { 
        if UNITY_ANDROID
            testToken = "856f987d813389d1243bea2e4731a0fb";  //Public Test Android
        #elif UNITY_
            testToken = "0b5dcbae8151c1b82d69697dce004bf2";  //Public Test iOS
        #endif
            
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        TapResearchSDK.TapResearchDidError = TapResearchDidError;

        TapResearchSDK.Configure(testToken, testUserId);
    }
    
    public void TapContentShown()
    {
        Debug.Log("Survey Content Opened");
    }

    public void TapContentDismissed()
    {
        Debug.Log("Survey Content Dismissed");
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

    public void showSurveyContent()
    {
        if (TapResearchSDK.CanShowContentForPlacement("default-placement")) //DefaultTest Placement
        {
            TapResearchSDK.ShowContentForPlacement("default-placement"); //DefaultTest Placement
        }
    }
    
    public void showSurveyContentWithParameters()
    {
        if (TapResearchSDK.CanShowContentForPlacement("default-placement")) //CustomParam Placement
        {
            Dictionary<string, string> customParameters = new Dictionary<string,string>(); //Parameters
            customParameters["some_string"] = "a string value";
            customParameters["some_number"] = "a number";   
            customParameters.Add("another_string", "it's another string!");
            Debug.Log("-> -> -> -> TapResearch customParameters:" + customParameters);
            
            TapResearchSDK.ShowContentForPlacement("default-placement", customParameters);
        }
        
    }
}
