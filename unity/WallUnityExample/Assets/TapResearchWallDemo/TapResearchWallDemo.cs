using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapResearchWallDemo : MonoBehaviour
{
    public GameObject wallButton;

    #if UNITY_ANDROID
    private static string tapAPIToken = "4aa77f4dc27e761d577d1189433cc62f"; // Public Test Android, replace with your own API token
    #elif UNITY_IPHONE
    private static string tapAPIToken = "100e9133abc21471c8cd373587e07515"; // Public Test iOS, replace with your own API token
    #else 
    private static string tapAPIToken = "NotAvailebleInEditor"; 
    #endif
    private static string tapPlayerUserId = "some-unique-user-identifier"; // Replace this with a unique user identifier, no user should have the same identifier 
    private static string placementTag = "earn-center";
                
    void Awake()
    {
        Screen.orientation = ScreenOrientation.Portrait;
        Debug.Log("TapResearchWallDemo: About to initialize Tap SDK");
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        TapResearchSDK.TapResearchDidError = TapResearchDidError;
        TapResearchSDK.TapResearchSdkReady = TapSdkReady;
        TapResearchSDK.Configure(tapAPIToken, tapPlayerUserId);
    }

    // START Callbacks
    
    public void TapContentShown(string placementTag)
    {
        Debug.Log("TapResearchWallDemo: Survey Content Opened");
    }

    public void TapContentDismissed(string placementTag)
    {
        Debug.Log("TapResearchWallDemo: Survey Content Dismissed");
    }

    public void TapSdkReady()
    {
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        wallButton.SetActive(false);
    }
    
    private void TapResearchRewardReceived(TRReward[] rewards) {
        Debug.Log("TapResearchWallDemo: TRReward received!");

        foreach (TRReward reward in rewards) 
        {
            Debug.Log("TapResearchWallDemo: Tap Rewards: You've earned " + reward.RewardAmount + " [" + reward.CurrencyName + "] TransactionIdentifier: " + reward.TransactionIdentifier + " PayoutEvent: ["+reward.PayoutEvent+"]");
        }
    }
    
    private void TapResearchDidError(TRError error) {
        Debug.Log("TapResearchWallDemo: TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + "");
    }
    
    // END Callbacks
    
    public void OnButtonClick()
    {
        Debug.Log("TapResearchWallDemo: TapResearchSDK OnButtonClick() attempting to show content");
        if (TapResearchSDK.CanShowContent(placementTag)) 
        {
            Debug.Log("TapResearchWallDemo: TapResearchSDK showSurveyContent() showing content");
            TapResearchSDK.ShowContentForPlacement(placementTag); 
        }
        else {
            Debug.Log("TapResearchWallDemo: TapResearchSDK showSurveyContent() content not available");
        }
    }

}
