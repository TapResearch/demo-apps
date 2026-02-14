
using UnityEngine;
using UnityEngine.SceneManagement;
using TapResearch;

public class SurveyWallExitButton : MonoBehaviour
{
    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample: SurveyWallExitButton OnButtonClick() reloading start scene");
        TapResearchSDK.TapResearchSurveysRefreshed = null;
        TapResearchSDK.TapResearchRewardReceived = null;
        SceneManager.LoadScene("TapResearchTestScene");
    }

}
 