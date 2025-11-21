package com.tapresearch.tapresearchkotlindemo

import android.app.AlertDialog
import android.content.Context
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
import com.tapresearch.tapresearchkotlindemo.preview.WallPreviewActivity
import com.tapresearch.tapresearchkotlindemo.ui.MainUi
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme
import com.tapresearch.tapsdk.TapInitOptions
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.TapResearch.getPlacementDetails
import com.tapresearch.tapsdk.callback.TRContentCallback
import com.tapresearch.tapsdk.callback.TRErrorCallback
import com.tapresearch.tapsdk.callback.TRGrantBoostResponseListener
import com.tapresearch.tapsdk.callback.TRQQDataCallback
import com.tapresearch.tapsdk.models.QQPayload
import com.tapresearch.tapsdk.models.TRError
import com.tapresearch.tapsdk.models.TRGrantBoostResponse
import com.tapresearch.tapsdk.models.TRReward
import kotlinx.serialization.InternalSerializationApi

@OptIn(InternalSerializationApi::class)
class MainActivity : ComponentActivity() {
    val LOG_TAG = "MainKotlinDemo"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val myUserIdentifier = "tr-sdk-test-user-46183135" // Insert your user identifier here
        val myApiToken = "fb28e5e0572876db0790ecaf6c588598" // Insert your API token here

        TapResearch.initialize(
            apiToken = myApiToken,
            userIdentifier = myUserIdentifier,
            activity = this@MainActivity,
            errorCallback = { trError -> showErrorToast(trError) },
            sdkReadyCallback = {

                Toast.makeText(
                    this@MainActivity,
                    "SDK is ready",
                    Toast.LENGTH_LONG,
                ).show()
                Log.d(LOG_TAG, "SDK is ready")
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
            qqDataCallback = object : TRQQDataCallback {
                override fun onQuickQuestionDataReceived(data: QQPayload) {
                    Log.d(LOG_TAG, "QQ data received: $data")
                }
            }
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
                        showWallPreview = {
                            startActivity(Intent(this, WallPreviewActivity::class.java))
                        },
                        onGrantBoostClicked = {onGrantBoostClicked()},
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

    override fun onDestroy() {
        super.onDestroy()
        Log.d(LOG_TAG, "onDestroy()")
    }

    private fun onGrantBoostClicked() {
        // 'boost-3x-1d' is an example boost tag
        TapResearch.grantBoost(
            "boost-3x-1d",
            TRGrantBoostResponseListener { grantBoostResponse: TRGrantBoostResponse? ->
                if (grantBoostResponse?.success == true) {
                    // example placement tag 'earn-center' should now be boosted

                    val placementDetails = getPlacementDetails("earn-center", null)
                    if (placementDetails != null) {
                        // 'earn-center' placement details should now be boosted
                        Log.d(LOG_TAG, "placement details: " + placementDetails)
                        showAlertDialog(
                            this@MainActivity,
                            "Placement Details",
                            placementDetails.toString()
                        )
                    }
                } else {
                    Toast.makeText(
                        this@MainActivity,
                        grantBoostResponse!!.error!!.description,
                        Toast.LENGTH_SHORT
                    ).show()
                    Log.d(
                        LOG_TAG,
                        "grantBoost error: " + grantBoostResponse.error!!.description
                    )
                }
            })
    }

    fun showAlertDialog(context: Context?, title: String?, message: String?) {
        val builder = AlertDialog.Builder(context)
        builder.setTitle(title)
        builder.setMessage(message)
        val dialog = builder.create()
        dialog.show()
    }
}
