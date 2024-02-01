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
import com.tapresearch.tapsdk.TapInitOptions
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.callback.TRContentCallback
import com.tapresearch.tapsdk.callback.TRErrorCallback
import com.tapresearch.tapsdk.callback.TRQQDataCallback
import com.tapresearch.tapsdk.models.QuickQuestion
import com.tapresearch.tapsdk.models.TRError
import com.tapresearch.tapsdk.models.TRReward

class MainActivity : ComponentActivity() {
    val LOG_TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val myUserIdentifier = "" // Insert your user identifier here
        val myApiToken = "" // Insert your API token here

        // Log if the user identifier and API token are set
        Log.d(LOG_TAG, "API Token: $myApiToken")
        Log.d(LOG_TAG, "User identifier: $myUserIdentifier")

        TapResearch.initialize(
            apiToken = "7f84af37b07c01f84ce3cc3e62fc6310",
            userIdentifier = "public-demo-test-user-2",
            activity = this@MainActivity,
            errorCallback = { trError -> showErrorToast(trError) },
            sdkReadyCallback = {
                showContent()
                Toast.makeText(
                    this@MainActivity,
                    "SDK is ready",
                    Toast.LENGTH_LONG,
                ).show()
                Log.d("MainActivity", "SDK is ready")
            },
            rewardCallback = { rewards ->
                showRewardToast(rewards)
            },
            initOptions = TapInitOptions(
                // Uncomment the following lines to set user attributes
//                userAttributes = hashMapOf(
//                    "is_vip" to 1,
//                ),
//                clearPreviousAttributes = true,
            ),
            tapDataCallback = object : TRQQDataCallback {
                override fun onQuickQuestionDataReceived(data: QuickQuestion) {
                    Log.d("MainActivity", "QQ data received: $data")
                }
            }
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
                        sendUserAttributes = {
                            TapResearch.sendUserAttributes(
                                userAttributes =
                                hashMapOf(
                                    "testStatus" to "VIP",
                                    "testInt" to 2,
                                ),
                                errorCallback =
                                object : TRErrorCallback {
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

    private fun showContent() {
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
                            // Test for Custom Parameters
                            val customParams: HashMap<String, Any> =
                                hashMapOf(
                                    "testKey" to "testValue",
                                )
                            TapResearch.showContentForPlacement(
                                tag = placementTag,
                                application = application,
                                customParameters = null,
                                contentCallback =
                                object : TRContentCallback {
                                    override fun onTapResearchContentShown(placementTag: String) {
                                        Log.d("MainActivity", "Content shown for $placementTag")
                                    }

                                    override fun onTapResearchContentDismissed(placementTag: String) {
                                        Log.d(
                                            "MainActivity",
                                            "Content dismissed for $placementTag",
                                        )
                                    }
                                },
                                errorCallback = object : TRErrorCallback {
                                    override fun onTapResearchDidError(trError: TRError) {
                                        showErrorToast(trError)
                                    }
                                },
                            )
                        },
                        onSetUserIdentifier = { userId ->
                            TapResearch.setUserIdentifier(
                                userIdentifier = userId,
                            )
                        },
                        sendUserAttributes = {
                            TapResearch.sendUserAttributes(
                                userAttributes =
                                hashMapOf(
                                    "testStatus" to "VIP",
                                    "testInt" to 2,
                                ),
                                errorCallback =
                                object : TRErrorCallback {
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
        var rewardAmount = 0f
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
