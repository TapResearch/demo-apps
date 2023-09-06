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
import java.time.Instant

class MainActivity : ComponentActivity() {
    val LOG_TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val myUserIdentifier = "public-demo-test-user"
        val myApiToken = getString(R.string.api_token)
        Log.d(LOG_TAG, "API Token: $myApiToken")
        Log.d(LOG_TAG, "User identifier: $myUserIdentifier")
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
                    val userAttributes: HashMap<String, Any> = HashMap()
                    userAttributes["age"] = 25
                    userAttributes["VIP"] = true
                    userAttributes["name"] = "John Doe"
                    userAttributes["first_seen"] = Instant.now().toString()
                    TapResearch.sendUserAttributes(
                        userAttributes,
                    ) { trError -> showErrorToast(trError) }
                    doSetContent()
                }
            },
            contentCallback = object : TRContentCallback {
                override fun onTapResearchContentDismissed(placementTag: String) {
                    contentDismissed(placementTag)
                }

                override fun onTapResearchContentShown(placementTag: String) {
                    contentShown(placementTag)
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
                        openPlacement = {},
                        onSetUserIdentifier = {},
                        buttonOptions = listOf("Waiting for SDK to initialize..."),
                    )
                }
            }
        }
    }

    private fun doSetContent() {
        val buttonOptions = resources.getStringArray(R.array.placement_tags)
        setContent {
            TapResearchKotlinDemoTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background,
                ) {
                    MainUi(
                        buttonOptions = buttonOptions.toList(),
                        openPlacement = { placementTag ->
                            if (TapResearch.canShowContentForPlacement(
                                    placementTag,
                                    errorCallback = object : TRErrorCallback {
                                        override fun onTapResearchDidError(trError: TRError) {
                                            trError.description?.let { Log.e(LOG_TAG, it) }
                                        }
                                    },
                                )
                            ) {
                                val customParameters: HashMap<String, Any> = HashMap()
                                customParameters["age"] = 25
                                customParameters["VIP"] = "true"
                                customParameters["name"] = "John Doe"

                                TapResearch.showContentForPlacement(
                                    placementTag,
                                    application,
                                    customParameters,
                                    object : TRErrorCallback {
                                        override fun onTapResearchDidError(trError: TRError) {
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
            Log.d(LOG_TAG, "Amount: ${reward.rewardAmount}")
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
}
