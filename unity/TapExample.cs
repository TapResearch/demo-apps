using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;

public class TapExample : MonoBehaviour
{
    private static string testToken = "f9c1b05047b88acaa9f08f35f4b3dad5"; //Nova-Unity
    private static string testUserId = "Nascar";

    void Awake()
    {
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
        if (TapResearchSDK.CanShowContentForPlacement("bd246a420312a623fdb3d1d5ef9fe262")) //DefaultTest Placement
        {
            TapResearchSDK.ShowContentForPlacement("bd246a420312a623fdb3d1d5ef9fe262"); //DefaultTest Placement
        }
    }
}
