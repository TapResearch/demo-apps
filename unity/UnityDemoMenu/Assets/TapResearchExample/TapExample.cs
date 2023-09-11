using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapExample : MonoBehaviour
{
    #if UNITY_ANDROID
        private static string tapApiToken = "4aa77f4dc27e761d577d1189433cc62f";  //Public Test Android
    #elif UNITY_IPHONE
        private static string tapApiToken = "100e9133abc21471c8cd373587e07515";  //Public Test iOS
    #else
        private static string tapApiToken = "";
    #endif

    private static string playerUserId = "public-demo-test-user";

    void Awake()
    {
        DontDestroyOnLoad(this);
        
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        TapResearchSDK.TapResearchDidError = TapResearchDidError;
        TapResearchSDK.TapResearchSdkReady =  TapSdkReady;
        
        TapResearchSDK.Configure(tapApiToken, playerUserId);
    }
    
    public void TapSdkReady() 
    {
        Debug.Log("TapResearchSDK Ready, sending user attributes");
 
        Dictionary<string, object> userAttributes = new Dictionary<string, object>();
        userAttributes["some_string"] = "a string value";
        userAttributes["some_number"] = "12";   
        userAttributes["another_number"] = 12;   
        userAttributes["boolean"] = true;
        userAttributes.Add("another_string", "it's another string!");

        TapResearchSDK.SendUserAttributes(userAttributes);
    }

    public void TapContentShown(string placementTag)
    {
        Debug.Log("TapResearch Content Opened");
    }

    public void TapContentDismissed(string placementTag)
    {
        Debug.Log("TapResearch Content Dismissed");
    }
    
    private void TapResearchRewardReceived(TRReward[] rewards) {
        foreach (TRReward reward in rewards)
        {
            Debug.Log("TapResearch Rewards: You've earned " + reward.RewardAmount + " " + reward.CurrencyName + ". " + reward.TransactionIdentifier);
        }
    }
    
    private void TapResearchDidError(TRError error) {
        Debug.Log("TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + "");
    }

}
