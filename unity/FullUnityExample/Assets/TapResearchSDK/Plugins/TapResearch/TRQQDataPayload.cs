using System;
using UnityEngine;

namespace TapResearch
{
#pragma warning disable 649
    
    [Serializable]
    public class TRQQDataPayload
    {
        [SerializeField] private string                        survey_identifier; //
        [SerializeField] private string                        app_name;          //
        [SerializeField] private string                        api_token;         //
        [SerializeField] private string                        sdk_version;       //
        [SerializeField] private string                        platform;          //
        [SerializeField] private string                        placement_tag;     //
        [SerializeField] private string                        user_identifier;   //
        [SerializeField] private string                        user_locale;       //
        [SerializeField] private string                        seen_at;           //
        [SerializeField] private TRQQDataPayloadQuestion[]     questions;         //
        [SerializeField] private TRQQDataPayloadTargetFilter[] target_audience;   //
        [SerializeField] private TRQQComplete                  complete;          //
		
		public string                        SurveyIdentifier { get { return survey_identifier; } }
		public string                        AppName          { get { return app_name;          } }
		public string                        ApiToken         { get { return api_token;         } }
		public string                        SdkVersion       { get { return sdk_version;       } }
		public string                        Platform         { get { return platform;          } }
		public string                        PlacementTag     { get { return placement_tag;     } }
		public string                        UserIdentifier   { get { return user_identifier;   } }
		public string                        UserLocale       { get { return user_locale;       } }
		public string                        SeenAt           { get { return seen_at;           } }
		public TRQQDataPayloadQuestion[]     Questions        { get { return questions;         } }
		public TRQQDataPayloadTargetFilter[] TargetAudience   { get { return target_audience;   } }
		public TRQQComplete                  Complete         { get { return complete;          } }
    }

    [Serializable]
    public class TRQQComplete
    {
        [SerializeField] private string complete_identifier; //
        [SerializeField] private string completed_at;        //
 		
		public string CompleteIdentifier { get { return complete_identifier; } }
		public string CompletedAt        { get { return completed_at;        } }
    }


    [Serializable]
    public class TRQQUserAnswer
    {
        [SerializeField] private string   value;       //
        [SerializeField] private string[] identifiers; //
 		
		public string   Value       { get { return value;       } } 		
		public string[] Identifiers { get { return identifiers; } }
    }

    [Serializable]
    public class TRQQDataPayloadQuestion
    {
        [SerializeField] private string         question_identifier; //
        [SerializeField] private string         question_text;       //
        [SerializeField] private string         question_type;       //
        [SerializeField] private string         rating_scale_size;   //
        [SerializeField] private TRQQUserAnswer user_answer;         //
 		
		public string         QuestionIdentifier { get { return question_identifier; } }
		public string         QuestionText       { get { return question_text;       } }
		public string         QuestionType       { get { return question_type;       } }
		public string         RatingScaleSize    { get { return rating_scale_size;   } }
		public TRQQUserAnswer UserAnswer         { get { return user_answer;         } }
    }

    [Serializable]
    public class TRQQDataPayloadTargetFilter
    {
        [SerializeField] private string filter_attribute_name; //
        [SerializeField] private string filter_operator;       //
        [SerializeField] private string filter_value;          //
        [SerializeField] private string user_value;            //
 		
		public string FilterAttributeName { get { return filter_attribute_name; } }
		public string FilterOperator      { get { return filter_operator;       } }
		public string FilterValue         { get { return filter_value;          } }
		public string UserValue           { get { return user_value;            } }
    }

}
