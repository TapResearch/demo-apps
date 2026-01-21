
using UnityEngine;
using UnityEngine.SceneManagement;
using TapResearch;

public class SurveyWallExitButton : MonoBehaviour
{
    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample: SurveyWallExitButton OnButtonClick() reloading start scene");
        // Since we set a reward delegate in the TapResearchTestScene, make sure to clear the reward delegate before loading that scene.
        // A simple way to manage this is the set the reward delegate in a GameObject that persists across scenes using DontDestroyOnLoad.
        TapResearchSDK.TapResearchSurveysRefreshed = null;
        SceneManager.LoadScene("TapResearchTestScene");
    }

}
