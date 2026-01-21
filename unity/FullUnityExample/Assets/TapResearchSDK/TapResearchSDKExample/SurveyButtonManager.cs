using UnityEngine;
using UnityEngine.UI;
using TapResearch;
using TMPro;
using System.Collections.Generic;

public class SurveyButtonManager : MonoBehaviour
{
    [SerializeField] private TRSurvey[] surveys;          // Array of TRSurvey objects
    [SerializeField] private GameObject buttonPrefab;     // Prefab for the buttons
    [SerializeField] private Transform buttonContainer;   // Parent object to hold the buttons
    private List<GameObject> buttons = new List<GameObject>();
    private string placementTag = "earn-center";         // Placement for this set of surveys

    void Start()
    {
        surveys = TapResearchSDK.GetSurveysForPlacement(placementTag);
        TapResearchSDK.SetEnableSurveysRefreshedCallback(true);
        Debug.Log("" + surveys);
        // Create a button for each survey in the array
        foreach (TRSurvey survey in surveys)
        {
            CreateSurveyButton(survey);
        }
    }

    void Awake() 
    {
        Debug.Log("TapResearchExample: SurveyButtonManager: set local delegates");
        TapResearchSDK.TapContentShown = TapContentShown;
        TapResearchSDK.TapContentDismissed = TapContentDismissed;
        TapResearchSDK.TapResearchRewardReceived = TapResearchRewardReceived;
        TapResearchSDK.TapResearchDidError = TapResearchDidError;
        TapResearchSDK.TapResearchSurveysRefreshed = TapResearchSurveysRefreshed;
    }

    void DeleteOldButtons() {
        var buttonCount = buttons.Count;
        for (int i = buttonCount - 1; i >= 0; i--) {
            Destroy(buttons[i]);
            buttons.RemoveAt(i);
        }
        // foreach (GameObject button in buttons) {
        //     Destroy(button);
        //     buttons.Remove(button);
        // }
        buttons.Clear();
    }

    void CreateSurveyButton(TRSurvey survey)
    {
        // Instantiate a new button from the prefab
        GameObject newButton = Instantiate(buttonPrefab, buttonContainer);
        buttons.Add(newButton);

        TextMeshProUGUI buttonText = newButton.GetComponentInChildren<TextMeshProUGUI>();
        if (buttonText != null)
        {
            string text = "" + survey.LengthInMinutes + (survey.LengthInMinutes == "1" ? " minute\nfor\n" : " minutes\nfor\n") + survey.RewardAmount + " " + survey.CurrencyName; 
            Debug.Log("button text: " + text);
            buttonText.text = text;
        }
        else 
        {
            Debug.Log("no button text found");
        }

        // Add a click listener to the button
        Button buttonComponent = newButton.GetComponent<Button>();
        if (buttonComponent != null)
        {
            buttonComponent.onClick.AddListener(() => OnSurveyButtonClicked(survey));
        }
    }

    void OnSurveyButtonClicked(TRSurvey survey)
    {
        // Handle the button click event, knowing which survey was clicked
        Debug.Log("Clicked survey: " + survey.SurveyIdentifier);
        
        TapResearchSDK.ShowSurveyForPlacement(survey.SurveyIdentifier, placementTag);
    }

    public void TapContentShown(string placementTag)
    {
        Debug.Log("TapResearchExample: SurveyButtonManager: Survey Content Opened");
    }

    public void TapContentDismissed(string placementTag)
    {
        Debug.Log("TapResearchExample: SurveyButtonManager: Survey Content Dismissed");
    }

    private void TapResearchRewardReceived(TRReward[] rewards) {

        foreach (TRReward reward in rewards)
        {
            Debug.Log("TapResearchExample: SurveyButtonManager: Tap Rewards: You've earned " + reward.RewardAmount + " " + reward.CurrencyName + ". " + reward.TransactionIdentifier);
        }
    }
    
    private void TapResearchDidError(TRError error) {
        Debug.Log("TapResearchExample: SurveyButtonManager: TapResearch Error:" + error.ErrorCode + " " + error.ErrorDescription + "");
    }

    private void TapResearchSurveysRefreshed(string placementTag) {
        Debug.Log("TapResearchExample: SurveyButtonManager: TapResearchSurveysRefreshed for placement: placementTag");
    
        surveys = TapResearchSDK.GetSurveysForPlacement(placementTag);
        Debug.Log("" + surveys);
        // Create a button for each survey in the array, but remove them all first...
        DeleteOldButtons();
        foreach (TRSurvey survey in surveys)
        {
            CreateSurveyButton(survey);
        }
    }

}
