
using UnityEngine;
using UnityEngine.SceneManagement;

public class ShowAvailableSurveysButton : MonoBehaviour
{
    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample: ShowAvailableSurveysButton OnButtonClick() attempting to show wall preview");
        SceneManager.LoadScene("WallPreviewScene");
    }

}
