using System;
using UnityEngine;

namespace TapResearch
{
	#pragma warning disable 649
	[Serializable]
	public struct TRPlacementDetails
	{
		[SerializeField] private string name;
		[SerializeField] private string contentType;
		[SerializeField] private string currencyName;
		[SerializeField] private bool   isSale;
		[SerializeField] private string saleType;
		[SerializeField] private string saleEndDate;
		[SerializeField] private double saleMultiplier;
		[SerializeField] private string saleDisplayName;
		[SerializeField] private string saleTag;
		
		public readonly string Name            { get { return name;            } }
		public readonly string ContentType     { get { return contentType;     } }
		public readonly string CurrencyName    { get { return currencyName;    } }
		public readonly bool   IsSale          { get { return isSale;          } }
		public readonly string SaleType        { get { return saleType;        } }
		public readonly string SaleEndDate     { get { return saleEndDate;     } }
		public readonly double SaleMultiplier  { get { return saleMultiplier;  } }
		public readonly string SaleDisplayName { get { return saleDisplayName; } }
		public readonly string SaleTag         { get { return saleTag;         } }
	}
}

