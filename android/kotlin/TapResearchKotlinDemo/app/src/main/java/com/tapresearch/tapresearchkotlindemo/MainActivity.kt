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
import com.tapresearch.tapsdk.callback.TRSdkReadyCallback
import com.tapresearch.tapsdk.models.TRError
import com.tapresearch.tapsdk.models.TRReward

class MainActivity : ComponentActivity() {
    val LOG_TAG = "MainActivity"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val myUserIdentifier = "public-demo-test-user"
        val myApiToken = getString(R.string.api_token)
        Log.d(LOG_TAG, "API Token: $myApiToken")
        Log.d(LOG_TAG, "User identifier: $myUserIdentifier")
        var tapSdkReady = false
        TapResearch.initialize(
            apiToken = getString(R.string.api_token),
            userIdentifier = myUserIdentifier,
            activity = this@MainActivity,
            rewardCallback = object : TRRewardCallback {
                override fun onTapResearchDidReceiveRewards(rewards: MutableList<TRReward>) {
                    showRewardToast(rewards)
                }
            },
            errorCallback = object : TRErrorCallback {
                override fun onTapResearchDidError(trError: TRError) {
                    showErrorToast(trError)
                }
            },
            sdkReadyCallback = object : TRSdkReadyCallback {
                override fun onTapResearchSdkReady() {
                    Log.d(LOG_TAG, "SDK is ready")
                    tapSdkReady = true
                }
            },
            contentCallback = object : TRContentCallback {
                override fun onContentShown(placementTag: String) {
                    contentShown(placementTag)
                }

                override fun onContentDismissed(placementTag: String) {
                    contentDismissed(placementTag)
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
                            if (!tapSdkReady) {
                                Toast.makeText(
                                    this@MainActivity,
                                    "SDK is not ready yet",
                                    Toast.LENGTH_LONG,
                                ).show()
                                return@MainUi
                            }
                            if (TapResearch.canShowContentForPlacement(
                                    placementTag,
                                    errorCallback = object : TRErrorCallback {
                                        override fun onTapResearchDidError(trError: TRError) {
                                            trError.description?.let { Log.e(LOG_TAG, it) }
                                        }
                                    },
                                )
                            ) {
                                TapResearch.showContentForPlacement(
                                    placementTag,
                                    application,
                                    object : TRErrorCallback {
                                        override fun onTapResearchDidError(trError: TRError) {
                                            showErrorToast(trError)
                                        }
                                    },
                                )
                            }
                        },
                        onSetUserIdentifier = { userId ->
                            if (!tapSdkReady) {
                                Toast.makeText(
                                    this@MainActivity,
                                    "SDK is not ready yet",
                                    Toast.LENGTH_LONG,
                                ).show()
                                return@MainUi
                            }
                            TapResearch.setUserIdentifier(
                                userIdentifier = userId,
                                errorCallback = object : TRErrorCallback {
                                    override fun onTapResearchDidError(trError: TRError) {
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

    private fun contentDismissed(tag: String) {
        Log.d(LOG_TAG, "dismissed: $tag")
    }

    private fun contentShown(tag: String) {
        Log.d(LOG_TAG, "shown: $tag")
    }

    private fun showErrorToast(error: TRError) {
        Log.d(LOG_TAG, "error: $error")
        Log.d(LOG_TAG, "error: ${error.javaClass.kotlin.qualifiedName}")
        Toast.makeText(
            this@MainActivity,
            error.description,
            Toast.LENGTH_LONG,
        ).show()
    }

    private fun showRewardToast(rewards: MutableList<TRReward>) {
        Log.d(LOG_TAG, "rewards: $rewards")
        var rewardAmount = 0
        for (reward: TRReward in rewards) {
            Log.d(LOG_TAG, "reward: $reward")
            Log.d(LOG_TAG, "Amount: ${reward?.rewardAmount}")
            reward.rewardAmount?.let { rewardAmount += it }
        }

        val currencyName = rewards.first().currencyName
        val eventType = rewards.first().payoutEventType
        Toast.makeText(
            this@MainActivity,
            "Congrats! You've earned $rewardAmount $currencyName. Event type is $eventType",
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
