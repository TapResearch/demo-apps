using System;
using UnityEngine;

namespace TapResearch
{
	#pragma warning disable 649
	[Serializable]
	public struct TRGrantBoostResponseError
	{
		[SerializeField] private string message;
		[SerializeField] private int    errorCode;
		
		public readonly string Message   { get { return message;   } }
		public readonly int    ErrorCode { get { return errorCode; } }
	}

	#pragma warning disable 649
	[Serializable]
	public struct TRGrantBoostResponse
	{
		[SerializeField] private string boostTag;
		[SerializeField] private bool   success;
		[SerializeField] private TRGrantBoostResponseError error;
			
		public readonly string BoostTag { get { return boostTag; } }
		public readonly bool   Success  { get { return success;  } }
		public readonly TRGrantBoostResponseError Error { get { return error;  } }
	}
}

