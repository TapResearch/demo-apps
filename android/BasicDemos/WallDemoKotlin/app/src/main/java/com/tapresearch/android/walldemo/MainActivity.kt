package com.tapresearch.android.walldemo

import BoxedText
import CenterHeadlineText
import ProgressIndicator
import android.content.Context
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.tapresearch.android.walldemo.ui.theme.WallDemoTheme
import com.tapresearch.tapsdk.TapInitOptions
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.callback.TRContentCallback
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update

class MainActivity : ComponentActivity() {

    val myPlacementTag = "earn-center"
    lateinit var myUserIdentifier: String // see initializeTapResearch()
    val myApiToken = "fb28e5e0572876db0790ecaf6c588598" // Sample API Token; replace in your production app
    val initializationStateFlow = MutableStateFlow(true) // initial state is 'initializing'

    fun initializeTapResearch() {

        /*
          Change user identifiers by passing in a different integer from 1 to 100
          to the SampleUserDatabase.getUserIdentifier function.
         */
        myUserIdentifier = SampleUserDatabase.getUserIdentifier(this, 1) // try different users from 1 to 100

        TapResearch.initialize(
            apiToken = myApiToken,
            userIdentifier = myUserIdentifier,
            activity = this@MainActivity,
            errorCallback = { trError -> showToast(this@MainActivity, trError.description) },
            sdkReadyCallback = {
                initializationStateFlow.update { false }
                Toast.makeText(
                    this@MainActivity,
                    "SDK is ready",
                    Toast.LENGTH_LONG,
                ).show()
            },
            rewardCallback = { rewards ->
                showToast(this@MainActivity, "Rewarded ${rewards.first().rewardAmount} ${rewards.first().currencyName}!")
            },
            initOptions = TapInitOptions(
                // Uncomment the following lines to set user attributes
//                userAttributes = hashMapOf(
//                    "is_vip" to 1,
//                ),
//                clearPreviousAttributes = true,
            ),
            qqDataCallback = null,
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            WallDemoTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    MainUI(modifier = Modifier.padding(innerPadding))
                }
            }
        }
        initializeTapResearch()
    }

    @Composable
    fun MainUI(modifier: Modifier = Modifier) {
        val initializing = initializationStateFlow.collectAsState()

        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {

            when (initializing.value) {
                true -> {
                    CenterHeadlineText("Initializing TapResearch SDK")
                    ProgressIndicator() // progress spinney
                    BoxedText("API Token:", myApiToken, "User Identifier:", myUserIdentifier)
                }
                false -> {
                    CenterHeadlineText("TapResearch SDK Ready")
                    BoxedText("API Token:", myApiToken, "User Identifier:", myUserIdentifier)
                    Button(
                        modifier = Modifier.padding(5.dp),
                        onClick = {
                            TapResearch.showContentForPlacement(
                                tag = myPlacementTag,
                                errorCallback = { trError -> showToast(this@MainActivity, trError.description) },
                                customParameters = hashMapOf("param1" to "value1", "param2" to "value2"),
                                contentCallback =
                                    object : TRContentCallback {
                                        override fun onTapResearchContentShown(placementTag: String) {
                                            showToast(this@MainActivity,"Content shown for $placementTag")
                                        }

                                        override fun onTapResearchContentDismissed(placementTag: String) {
                                            showToast(this@MainActivity,"Content dismissed for $placementTag")
                                        }
                                    },
                            )
                        },
                    ) {
                        Text(text = "Show Content For Placement: $myPlacementTag")
                    }
                }
            }
        }
    }
}

fun showToast(context: Context, error: String?) {
    Toast.makeText(
        context,
        error,
        Toast.LENGTH_LONG,
    ).show()
}

/**
 * Mock user database
 *
 */
object SampleUserDatabase {
    fun getUserIdentifier(context: Context, index: Int): String {
        val androidId = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
        return "tr-sdk-test-user-$index--$androidId"
    }
}