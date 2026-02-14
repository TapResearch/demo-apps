using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace TapResearch
{
#pragma warning disable 649
    [Serializable]
    public static class TRConvert
    {
        public static string DictionaryToJsonString(Dictionary<string, object> dict)
        {
            var jsonString = "{";
            var i = 0;
            foreach (var item in dict)
            {
                if (i > 0)
                {
                    jsonString += ", ";
                }
                i++;
                var itemKey = item.Key;
                var itemValue = item.Value;
                if (itemValue is sbyte ||
                    itemValue is byte ||
                    itemValue is short ||
                    itemValue is ushort ||
#if UNITY_2021_2_OR_NEWER
                    itemValue is nint ||
                    itemValue is nuint ||
#endif
                    itemValue is int ||
                    itemValue is uint ||
                    itemValue is long ||
                    itemValue is ulong ||
                    itemValue is float ||
                    itemValue is double ||
                    itemValue is decimal)
                {
                    //Debug.LogError("itemValue is a numberical or boolean value: " + itemKey + "=" + itemValue);
                    jsonString += "\"" + itemKey + "\" : " + itemValue;
                }
                else if (itemValue is bool)
                {
                    // Unity "prints" a bool as True or False but for correct JSON we need true or false.
                    jsonString += "\"" + itemKey + "\" : " + ((bool)itemValue ? "\"true\"" : "\"false\"");
                }
                else if (itemValue is string || itemValue is char)
                {
                    //Debug.LogError("itemValue is a string or char: " + itemKey + "=" + itemValue);
                    jsonString += "\"" + itemKey + "\" : \"" + itemValue + "\"";
                }
                else
                {
                    Debug.LogError("TapResearch: Error while parsing attributes: value for " + itemKey + " cannot be parsed.");
                }
            }
            jsonString += "}";
            return jsonString;
        }
    }
}
