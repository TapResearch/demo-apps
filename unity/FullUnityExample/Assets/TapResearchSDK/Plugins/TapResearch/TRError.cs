using System;
using UnityEngine;

namespace TapResearch
{
#pragma warning disable 649
    [Serializable]
    public struct TRError
    {
        [SerializeField] private int errorCode;

        [SerializeField] private string errorDescription;

        public readonly int ErrorCode
        {
            get { return errorCode; }
        }

        public readonly string ErrorDescription
        {
            get { return errorDescription; }
        }
    }
}
