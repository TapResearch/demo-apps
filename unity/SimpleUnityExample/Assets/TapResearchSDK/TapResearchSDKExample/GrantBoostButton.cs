
using System;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TapResearch;
using TMPro;
using System.Collections.Generic;

public class GrantBoostButton : MonoBehaviour
{
    
    public TMP_InputField inputField;

    void Awake()
    {
        Debug.Log("TapResearchExample:GrantBoostButton:Awake()");
    }

    public void OnButtonClick()
    {
        Debug.Log("TapResearchExample:GrantBoostButton:OnButtonClick() CLICKED!!!!!!!!!!!!!!!!!!!!!");
        Debug.Log("TapResearchExample:GrantBoostButton:OnButtonClick() attempting to grant boost " + inputField.text);
        TapResearchSDK.TapResearchGrantBoostResponse = TapResearchGrantBoostResponse;
        if (inputField.text != "")
        {
            TapResearchSDK.GrantBoost(inputField.text);
        }

    }

    private void TapResearchGrantBoostResponse(TRGrantBoostResponse response)
    {
        if (response.Success)
        {
            Debug.Log("TapResearchExample:GrantBoostButton:TRGrantBoostResponseReceived success for " + response.BoostTag);
        }
        else
        {
            Debug.Log("TapResearchExample:GrantBoostButton:TRGrantBoostResponseReceived error for " + response.BoostTag + ", " + response.Error.Message);
        }
    }
    
}
