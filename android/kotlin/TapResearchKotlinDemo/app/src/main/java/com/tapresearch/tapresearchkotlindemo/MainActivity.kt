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
import com.tapresearch.tapsdk.callback.TRRewardCallback
import com.tapresearch.tapsdk.models.PlacementCustomParameters
import com.tapresearch.tapsdk.models.TRError
import com.tapresearch.tapsdk.models.TRPlacement
import com.tapresearch.tapsdk.models.TRReward

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val myUserIdentifier = "public-demo-test-user"
        val myApiToken = "856f987d813389d1243bea2e4731a0fb"
        Log.d("MainActivity", "API Token: $myApiToken")
        Log.d("MainActivity", "User identifier: $myUserIdentifier")

        val customParams = PlacementCustomParameters().fromMap(mapOf("thing" to "thing"))

        TapResearch.initialize(
            apiToken = myApiToken,
            userIdentifier = myUserIdentifier,
            activity = this@MainActivity,
            rewardCallback = object : TRRewardCallback {
                override fun onReward(rewards: MutableList<TRReward>) {
                    showRewardToast(rewards)
                }
            },
            errorCallback = object : TRErrorCallback {
                override fun onError(trError: TRError) {
                    showErrorToast(trError)
                }
            },
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
                            if (TapResearch.canShowContentForPlacement(
                                    placementTag,
                                    errorCallback = object : TRErrorCallback {
                                        override fun onError(trError: TRError) {
                                            trError.description?.let { Log.e("TRERROR", it) }
                                        }
                                    },
                                )
                            ) {
                                TapResearch.showContentForPlacement(
                                    placementTag,
                                    application,
                                    customParams,
                                    object : TRContentCallback {
                                        override fun onContentShown(placement: TRPlacement) {
                                            tapResearchDidDismiss(placement)
                                        }

                                        override fun onContentDismissed(placement: TRPlacement) {
                                            tapResearchContentShown(placement)
                                        }
                                    },
                                    object : TRErrorCallback {
                                        override fun onError(trError: TRError) {
                                            showErrorToast(trError)
                                        }
                                    },
                                )
                            }
                        },
                        onSetUserIdentifier = { userId ->
                            TapResearch.setUserIdentifier(
                                userIdentifier = userId,
                                errorCallback = object : TRErrorCallback {
                                    override fun onError(trError: TRError) {
                                        showErrorToast(trError)
                                    }
                                },
                            )
                        },
                    )
                }
            }
        }
    }

    private fun tapResearchDidDismiss(trPlacement: TRPlacement) {
        if (trPlacement.error != null) {
            Log.e("TRERROR", "Error: ${trPlacement.error}")
        }
        Log.d("TR", "dismissed: $trPlacement")
    }

    private fun tapResearchContentShown(trPlacement: TRPlacement) {
        if (trPlacement.error != null) {
            Log.e("TRERROR", "Error: ${trPlacement.error}")
        }
        Log.d("TR", "shown: $trPlacement")
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
        const val CP_INTERSTITIAL_OFFER = "capped-and-paced-interstitial-a"
    }
}
