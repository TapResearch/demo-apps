using System;
using UnityEngine;

namespace TapResearch
{
#pragma warning disable 649
    [Serializable]
    public class TRSurvey
    {
	    [SerializeField] private string surveyIdentifier;
	    [SerializeField] private string currencyName;
	    [SerializeField] private int    lengthInMinutes;
	    [SerializeField] private double rewardAmount;
	    [SerializeField] private bool   isHotTile;
	    [SerializeField] private bool   isSale;
	    [SerializeField] private double saleMultiplier;
	    [SerializeField] private double preSaleRewardAmount;
	    [SerializeField] private string saleEndDate;
	 
        public string SurveyIdentifier    { get { return surveyIdentifier;    } }
        public string CurrencyName        { get { return currencyName;        } }
		public int    LengthInMinutes     { get { return lengthInMinutes;     } }
		public double RewardAmount        { get { return rewardAmount;        } }
		public bool   IsHotTile           { get { return isHotTile;           } }
		public bool   IsSale              { get { return isSale;              } }
		public double SaleMultiplier      { get { return saleMultiplier;      } }
		public double PreSaleRewardAmount { get { return preSaleRewardAmount; } }
		public string SaleEndDate         { get { return saleEndDate;         } }
    }
}
