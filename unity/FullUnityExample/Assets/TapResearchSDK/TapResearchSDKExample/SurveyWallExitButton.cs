
using UnityEngine;
using UnityEngine.SceneManagement;
using TapResearch;

public class SurveyWallExitButton : MonoBehaviour
{
    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample: SurveyWallExitButton OnButtonClick() reloading start scene");
        TapResearchSDK.SetEnableSurveysRefreshedCallback(false);
        SceneManager.LoadScene("TapResearchTestScene");
    }

}
