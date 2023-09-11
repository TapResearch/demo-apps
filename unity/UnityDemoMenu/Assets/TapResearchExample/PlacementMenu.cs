using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using TapResearch;
using TMPro;
using UnityEngine;

public class PlacementMenu : MonoBehaviour
{

    public void ShowHomeScreen()
    {
        string ptag = "home-screen";
        if (TapResearchSDK.CanShowContent(ptag))
        {
            TapResearchSDK.ShowContentForPlacement(ptag);
        }    
    }

    public void ShowEarnCenter()
    {
        string ptag = "earn-center";
        if (TapResearchSDK.CanShowContent(ptag))
        {
            TapResearchSDK.ShowContentForPlacement(ptag);
        }    
    }
    
    public void ShowInterstitial()
    {
        string ptag = "mike-interstitial";
        if (TapResearchSDK.CanShowContent(ptag))
        {
            TapResearchSDK.ShowContentForPlacement(ptag);
        }    
    }

    public void ShowSurveys()
    {
        string ptag = "manual-placement-for-survey-walls";
        if (TapResearchSDK.CanShowContent(ptag))
        {
            // Example Custom Parameters
            Dictionary<string, object> customParameters = new Dictionary<string, object>();
            customParameters.Add("string", "string");
            customParameters.Add("number", 12);
            
            TapResearchSDK.ShowContentForPlacement(ptag, customParameters);
        }
    }

}
