package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen

import android.util.Log
import androidx.compose.foundation.lazy.staggeredgrid.LazyStaggeredGridState
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tapresearch.tapresearchkotlindemo.preview.common.Resource
import com.tapresearch.tapresearchkotlindemo.preview.domain.use_case.get_surveys.SurveysState
import com.tapresearch.tapresearchkotlindemo.preview.domain.use_case.get_surveys.SurveysUseCase
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.callback.TRRewardCallback
import com.tapresearch.tapsdk.callback.TRSurveysRefreshedListener
import com.tapresearch.tapsdk.models.TRReward
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.plus
import javax.inject.Inject

@HiltViewModel
class WallPreviewViewModel @Inject constructor(private val surveysUseCase: SurveysUseCase,
                                               savedStateHandle: SavedStateHandle):
    ViewModel(),
    TRSurveysRefreshedListener,
    TRRewardCallback,
    DefaultLifecycleObserver
{
    private val _surveysState = MutableStateFlow(SurveysState())
    val surveysState = _surveysState.asStateFlow()
    val lazyStaggeredGridState: LazyStaggeredGridState = LazyStaggeredGridState(0, 0)

    private val _rewardsState = MutableStateFlow(RewardsState())
    val rewardsState = _rewardsState.asStateFlow()

    init {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
        getSurveys()
        TapResearch.setSurveysRefreshedListener(this)
    }

    override fun onSurveysRefreshedForPlacement(placementTag: String) {
        if (WallPreviewConfig.currentPlacementTag == placementTag) {
            getSurveys()
        }
    }

    fun getSurveys() {
        surveysUseCase(WallPreviewConfig.currentPlacementTag)
            .distinctUntilChanged()
            .onEach { result ->
                when (result) {
                    is Resource.Loading -> {
                        _surveysState.update {
                            it.copy(isLoading = true)
                        }
                    }
                    is Resource.Success -> {
                        _surveysState.update {
                            it.copy(
                                isLoading = false,
                                surveys = result.data?: emptyList(),
                                error = ""
                            )
                        }
                    }
                    is Resource.Error -> {
                        _surveysState.update {
                            it.copy(
                                isLoading = false,
                                error = result.message
                                    ?: "Unexpected Error Occurred. Please try again."
                            )
                        }
                    }
                }
            }.launchIn(viewModelScope + SupervisorJob())
    }

    fun showSurveyForPlacement(surveyId: String,
                               onShowSurveyError : (errorMessage: String) -> Unit) {
        TapResearch.showSurveyForPlacement(WallPreviewConfig.currentPlacementTag, surveyId) { error ->
            onShowSurveyError("Show Survey Error: ${error.description}")
        }
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        TapResearch.setRewardCallback(this)
        Log.d("SurveyWallViewModel", "onResume")
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
        TapResearch.setRewardCallback(null)
        Log.d("SurveyWallViewModel", "onPause")
    }

    override fun onTapResearchDidReceiveRewards(rewards: MutableList<TRReward>) {
        Log.d("SurveyWallViewModel", "onTapResearchDidReceiveRewards: $rewards")
        _rewardsState.update {
            it.copy(
                rewards = it.rewards + rewards
            )
        }
    }
}

