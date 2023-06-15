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
import com.tapresearch.tapresearchkotlinsdk.TapResearch
import com.tapresearch.tapresearchkotlinsdk.models.TRError
import com.tapresearch.tapresearchkotlinsdk.models.TRReward
import com.tapresearch.tapresearchkotlinsdk.state.TRContentState
import io.github.cdimascio.dotenv.dotenv

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val dotenv = dotenv {
            directory = "./assets"
            filename = "env"
            ignoreIfMalformed = true
            ignoreIfMissing = true
        }
        val myUserIdentifier = "public-demo-test-user"
        val myApiToken = dotenv["API_TOKEN"]
        Log.d("MainActivity", "API Token: $myApiToken")
        Log.d("MainActivity", "User identifier: $myUserIdentifier")

        TapResearch.initialize(
            apiToken = myApiToken,
            userIdentifier = myUserIdentifier,
            activity = this,
            rewardCallback = { rewards -> showRewardToast(rewards) },
            errorCallback = { trError -> showErrorToast(trError) },
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
                                contentCallback = { trPlacement, trContentState ->
                                    run {
                                        val action =
                                            if (trContentState == TRContentState.ContentShown) "Content Shown" else "Content Dismissed"
                                        Log.d("MainActivity", "$action for placement: $trPlacement.tag")
                                    }
                                },
                                errorCallback = { trError -> showErrorToast(trError) },
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
