using System.Collections;
using System.Collections.Generic;
using TapResearch;
using UnityEngine;
using UnityEngine.SceneManagement;

public class TapResearchExample : MonoBehaviour
{
    public string surveysPlacementTag;
    public GameObject showSurveysButton;
    public GameObject hasSurveysButton;

    #if UNITY_ANDROID
    private static string tapAPIToken = "YOUR_ANDROID_API_TOKEN"; // Public Test Android, replace with your own API token
    #elif UNITY_IPHONE
    private static string tapAPIToken = "YOUR_IOS_API_TOKEN";  // Public Test iOS, replace with your own API token
    #else
    private static string tapAPIToken = "NotAvailebleInEditor";
    #endif
    private static string tapPlayerUserId = "some-unique-user-identifier"; // Replace this with a unique user identifier, no user should have the same identifier
    private static string placementTag = "earn-center";

    void Awake()
    {
        Screen.orientation = ScreenOrientation.Portrait;
        Debug.Log("TapResearchExample: About to initialize Tap SDK");
        TapResearchSDK.TapResearchDidError = TapResearchDidError;
        TapResearchSDK.TapResearchSdkReady = TapSdkReady;
        TapResearchSDK.Configure(tapAPIToken, tapPlayerUserId);
    }

    // START Callbacks

    private void TapSdkReady()
    {
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        hasSurveysButton.SetActive(true);
    }

    private void TapResearchRewardReceived(TRReward[] rewards)
    {
        foreach (TRReward reward in rewards)
        {
            Debug.Log("TapResearchExample: Tap Rewards: You've earned " + reward.RewardAmount + " " + reward.CurrencyName + ". " + reward.TransactionIdentifier);
        }
    }

    private void TapResearchDidError(TRError error)
    {
        Debug.Log("TapResearchExample: TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + "");
    }

    // END Callbacks

    public void OnShowSurveysButtonClick()
    {
        Debug.Log("TapResearchExample: ShowAvailableSurveysButton OnButtonClick() attempting to show wall preview");
        // Since we set a reward delegate in the WallPreviewScene, make sure to clear the reward delegate before loading that scene.
        // A simple way to manage this is the set the reward delegate in a GameObject that persists across scenes using DontDestroyOnLoad.
        TapResearchSDK.TapResearchSurveysRefreshed = null;
        SceneManager.LoadScene("WallPreviewScene");
    }

    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample: TapResearchSDK OnButtonClick() checking for surveys");
        if (TapResearchSDK.HasSurveys(placementTag))
        {
            Debug.Log("TapResearchExample: TapResearchSDK OnButtonClick() has surveys, enabling show button");
            showSurveysButton.SetActive(true);
        }
        else
        {
            Debug.Log("TapResearchExample: TapResearchSDK OnButtonClick() no surveys");
            showSurveysButton.SetActive(false);
        }
    }

}
