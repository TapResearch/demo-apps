
using UnityEngine;
using UnityEngine.SceneManagement;
using TapResearch;

public class ShowAvailableSurveysButton : MonoBehaviour
{
    public void OnButtonClick()
    {
        TapResearchSDK.TapResearchQQResponseReceived = null;
        TapResearchSDK.TapResearchRewardReceived = null;
        Debug.Log("TapResearchExample: ShowAvailableSurveysButton OnButtonClick() attempting to show wall preview");
        SceneManager.LoadScene("WallPreviewScene");
    }

}
