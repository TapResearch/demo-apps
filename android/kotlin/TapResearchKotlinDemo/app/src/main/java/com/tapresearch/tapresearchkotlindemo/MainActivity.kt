package com.tapresearch.tapresearchkotlindemo

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.tapresearch.tapresearchkotlindemo.ui.MainUi
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.callback.TRContentCallback
import com.tapresearch.tapsdk.callback.TRErrorCallback
import com.tapresearch.tapsdk.models.TRError
import com.tapresearch.tapsdk.models.TRPlacement
import com.tapresearch.tapsdk.models.TRReward
import com.tapresearch.tapsdk.state.TRContentState

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val myUserIdentifier = "public-demo-test-user"
        val myApiToken = "856f987d813389d1243bea2e4731a0fb"
        Log.d("MainActivity", "API Token: $myApiToken")
        Log.d("MainActivity", "User identifier: $myUserIdentifier")

        TapResearch.initialize(
            apiToken = myApiToken,
            userIdentifier = myUserIdentifier,
            activity = this
        )
        setContent {
            TapResearchKotlinDemoTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background,
                ) {
                    MainUi(
                        openPlacement = { placementTag ->
                            TapResearch.showContentForPlacement(
                                placementTag,
                                application,
                                object : TRContentCallback {
                                    override fun onContentShown(placement: TRPlacement) {
                                        handleContentCallback(placementTag, TRContentState.ContentShown)
                                    }
                                    override fun onContentDismissed(placement: TRPlacement) {
                                        handleContentCallback(placementTag, TRContentState.ContentDismissed)
                                    }
                                },
                                object : TRErrorCallback {
                                    override fun onError(trError: TRError) {
                                        showErrorToast(trError)
                                    }
                                }
                            )
                        },
                        onSetUserIdentifier = { userId ->
                            TapResearch.setUserIdentifier(
                                userIdentifier = userId,
                                errorCallback = { trError -> showErrorToast(trError) },
                            )
                        },
                    )
                }
            }
        }
    }

    private fun handleContentCallback(placementTag: String, trContentState: TRContentState) {
        Log.d("TapResearchSDK - KTBridge: ", "handleContentCallback")
        if (trContentState.equals(TRContentState.ContentShown)) {
            tapResearchContentShown(placementTag)
        } else {
            tapResearchDidDismiss(placementTag)
        }
    }

    private fun tapResearchDidDismiss(placementTag: String) {
        TODO("Not yet implemented")
    }

    private fun tapResearchContentShown(placementTag: String) {
            TODO("Not yet implemented")
    }

    private fun showErrorToast(error: TRError) {
        Toast.makeText(
            this@MainActivity,
            error.description,
            Toast.LENGTH_LONG,
        ).show()
    }
    private fun showRewardToast(rewards: MutableList<TRReward>) {
        var rewardCount = 0
        for (reward: TRReward in rewards) {
            Log.d("MainActivity", "reward: $reward")
            reward.rewardAmount?.let { rewardCount += it }
        }

        val currencyName = rewards.first().currencyName
        val eventType = rewards.first().payoutEventType
        Toast.makeText(
            this@MainActivity,
            "Congrats! You've earned $rewardCount $currencyName. Event type is $eventType",
            Toast.LENGTH_LONG,
        ).show()
    }

    companion object {
        const val NORMAL_OFFER = "default-placement-a"
        const val BANNER_OFFER = "banner-placement-a"
        const val INTERSTITIAL_OFFER = "interstitial-placement-a"
        const val PARTIAL_INTERSTITIAL_OFFER = "floating-interstitial-placement-a"
    }
}
