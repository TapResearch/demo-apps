package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen

import com.tapresearch.tapsdk.models.TRReward

data class RewardsState(
    val isLoading: Boolean = false,
    val rewards: List<TRReward> = emptyList(),
    val error: String = ""
)
