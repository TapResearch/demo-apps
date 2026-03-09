package com.tapresearch.tapresearchkotlindemo

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.tapresearch.tapresearchkotlindemo.preview.SurveyWallPreviewActivity
import com.tapresearch.tapresearchkotlindemo.ui.MainUi
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme
import com.tapresearch.tapsdk.TapInitOptions
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.callback.TRContentCallback
import com.tapresearch.tapsdk.callback.TRErrorCallback
import com.tapresearch.tapsdk.callback.TRQQDataCallback
import com.tapresearch.tapsdk.callback.TRRewardCallback
import com.tapresearch.tapsdk.models.QQPayload
import com.tapresearch.tapsdk.models.TRError
import com.tapresearch.tapsdk.models.TRReward
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update

class MainActivity : ComponentActivity(), TRRewardCallback {
    val LOG_TAG = "TapKotlinDemo"

    private val initializingStateFlow = MutableStateFlow(true)

    override fun onTapResearchDidReceiveRewards(rewards: MutableList<TRReward>) {
        showRewardToast(rewards)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val myUserIdentifier = "tr-sdk-test-user-46183135" // Try a different user identifier by changing the number at the end
        val myApiToken = "fb28e5e0572876db0790ecaf6c588598" // Insert your API token here

        TapResearch.initialize(
            apiToken = myApiToken,
            userIdentifier = myUserIdentifier,
            activity = this@MainActivity,
            errorCallback = { error -> showErrorToast(error) },
            sdkReadyCallback = {

                initializingStateFlow.update { false }
                Log.d(LOG_TAG, "SDK is ready")
                // you can query placement details when sdk is ready
                // printPlacementDetails()
            },
            rewardCallback = this@MainActivity,
            initOptions = TapInitOptions(
                // Uncomment the following lines to set user attributes
//                userAttributes = hashMapOf(
//                    "is_vip" to 1,
//                ),
//                clearPreviousAttributes = true,
            ),
            qqDataCallback = object : TRQQDataCallback {
                override fun onQuickQuestionDataReceived(data: QQPayload) {
                    Log.d(LOG_TAG, "QQ data received: $data")
                }
            },
        )

        val buttonOptions = resources.getStringArray(R.array.placement_tags)

        setContent {
            TapResearchKotlinDemoTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background,
                ) {
                    MainUi(
                        userIdentifier = myUserIdentifier,
                        buttonOptions = buttonOptions.toList(),
                        openPlacement = { placementTag ->
                            // Test for Custom Parameters
                            val customParams: HashMap<String, Any> =
                                hashMapOf(
                                    "testKey" to "testValue",
                                )
                            TapResearch.showContentForPlacement(
                                tag = placementTag,
                                customParameters = null,
                                contentCallback =
                                object : TRContentCallback {
                                    override fun onTapResearchContentShown(placementTag: String) {
                                        Log.d(LOG_TAG, "Content shown for $placementTag")
                                    }

                                    override fun onTapResearchContentDismissed(placementTag: String) {
                                        Log.d(
                                            LOG_TAG,
                                            "Content dismissed for $placementTag",
                                        )
                                    }
                                },
                                errorCallback = TRErrorCallback { error -> showErrorToast(error) },
                            )
                        },
                        onSetUserIdentifier = { userId ->
                            TapResearch.setUserIdentifier(
                                userIdentifier = userId,
                            )
                            Toast.makeText(this@MainActivity, "SetUserIdentifier: $userId", Toast.LENGTH_SHORT).show()
                        },
                        sendUserAttributes = {
                            TapResearch.sendUserAttributes(
                                userAttributes =
                                hashMapOf(
                                    "testStatus" to "VIP",
                                    "testInt" to 2,
                                ),
                                errorCallback =
                                    TRErrorCallback { error -> showErrorToast(error) },
                            )
                            Toast.makeText(this@MainActivity, "Sent User Attributes", Toast.LENGTH_SHORT).show()
                            Log.d(LOG_TAG, "Sent User Attributes")
                        },
                        showWallPreview = {
                            startActivity(Intent(this, SurveyWallPreviewActivity::class.java))
                        },
                        onGetPlacementDetailsClicked = {
                            printPlacementDetails()
                        },
                        initializingStateFlow = initializingStateFlow,
                    )
                }
            }
        }
    }

    private fun printPlacementDetails() {
        val placementDetails = TapResearch.getPlacementDetails(
            placementTag = "earn-center",
        ){}
        Log.d(LOG_TAG, "Placement Details: $placementDetails")
        alertDialog("Placement Details: $placementDetails")

    }

    override fun onResume() {
        super.onResume()
        TapResearch.setRewardCallback(this@MainActivity)
    }

    override fun onPause() {
        super.onPause()
        TapResearch.setRewardCallback(null)
    }

    private fun contentDismissed(tag: String) {
        Log.d(LOG_TAG, "dismissed: $tag")
    }

    private fun contentShown(tag: String) {
        Log.d(LOG_TAG, "shown: $tag")
    }

    private fun showErrorToast(error: TRError) {
        initializingStateFlow.update{false}
        Log.d(LOG_TAG, "error: $error")
        alertDialog(error.description?:"Unknown Error")
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
        alertDialog("Congrats! You've earned $rewardAmount $currencyName. Event type is $eventType")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(LOG_TAG, "onDestroy()")
    }

    private fun alertDialog(message: String) {
        val builder = AlertDialog.Builder(this)
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ ->
                dialog.dismiss()
            }
        val alertDialog = builder.create()
        alertDialog.show()
    }

}
