using System;
using UnityEngine;

namespace TapResearch
{
#pragma warning disable 649
    [Serializable]
    public struct TRReward
    {
        [SerializeField] private string transactionIdentifier;

        [SerializeField] private string currencyName;

        [SerializeField] private string placementIdentifier;

        [SerializeField] private string placementTag;

        [SerializeField] private int rewardAmount;

        [SerializeField] private string payoutEvent;

        public readonly string TransactionIdentifier
        {
            get { return transactionIdentifier; }
        }

        public readonly string CurrencyName
        {
            get { return currencyName; }
        }

        public readonly string PlacementIdentifier
        {
            get { return placementIdentifier; }
        }

        public readonly string PlacementTag
        {
            get { return placementTag; }
        }

        public readonly int RewardAmount
        {
            get { return rewardAmount; }
        }

        public readonly string PayoutEvent
        {
            get { return payoutEvent; }
        }
    }
}