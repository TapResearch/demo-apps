package com.tapresearch.kotlinsdk.preview.domain.use_case.get_surveys

import com.tapresearch.tapsdk.models.TRSurvey

data class SurveysState(
    val isLoading: Boolean = false,
    val surveys: List<TRSurvey> = emptyList(),
    val error: String = ""
)
