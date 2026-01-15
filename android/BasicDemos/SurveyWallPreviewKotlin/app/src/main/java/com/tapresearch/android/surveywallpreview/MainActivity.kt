package com.tapresearch.android.surveywallpreview

import BoxedText
import CenterFullScreenText
import CenterHeadlineText
import CenterMediumText
import ProgressIndicator
import android.content.Context
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.tapresearch.android.surveywallpreview.ui.SurveyTileConfig
import com.tapresearch.android.surveywallpreview.ui.theme.SurveyWallPreviewTheme
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen.SurveyTile
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.models.TRSurvey
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

class MainActivity : ComponentActivity() {

    val myPlacementTag = "earn-center"
    lateinit var myUserIdentifier: String // see initializeTapResearch()
    val myApiToken = "fb28e5e0572876db0790ecaf6c588598" // Sample API Token; replace in your production app
    val surveysStateFlow = MutableStateFlow(SurveysState())
    val initializationStateFlow = MutableStateFlow(true)

    fun initializeTapResearch() {

        /*
          Change user identifiers by passing in a different integer from 1 to 100
          to the SampleUserDatabase.getUserIdentifier function.
         */
        myUserIdentifier = SampleUserDatabase.getUserIdentifier(this, 1) // try different users from 1 to 100

        TapResearch.initialize(
            context = this@MainActivity,
            apiToken = myApiToken,
            userIdentifier = myUserIdentifier,
            errorCallback = { trError -> showToast(this@MainActivity,trError.description) },
            sdkReadyCallback = {
                initializationStateFlow.update{ false }
                updateSurveys(myPlacementTag)
            },
            rewardCallback = { rewards ->
                showToast(this@MainActivity,"Rewarded ${rewards.first().rewardAmount} ${rewards.first().currencyName}!")
            },
            initOptions = null,
            qqDataCallback = null,
        )
    }

    fun updateSurveys(placementTag: String) {
        if (TapResearch.isReady()) {
            val updatedSurveys = TapResearch.getSurveysForPlacement(placementTag) { error ->
                showToast(this@MainActivity, error.description)
            }
            updatedSurveys?.let { surveys ->
                surveysStateFlow.update { SurveysState(surveys) }
            }
            Log.d("MainActivity", "Surveys updated: ${updatedSurveys?.size}")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SurveyWallPreviewTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    MainUI(modifier = Modifier.padding(innerPadding))
                }
            }
        }
        initializeTapResearch()
    }

    override fun onResume() {
        super.onResume()
        updateSurveys(myPlacementTag)
        TapResearch.setSurveysRefreshedListener { placementTag ->
            updateSurveys(placementTag)
        }
    }

    override fun onPause() {
        super.onPause()
        TapResearch.setSurveysRefreshedListener(null)
    }

    @Composable
    fun MainUI(modifier: Modifier = Modifier) {
        val initializing = initializationStateFlow.collectAsState()
        val context = LocalContext.current

        Column(
            modifier = modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.Center
        ) {

            if (initializing.value) {
                CenterHeadlineText("Initializing TapResearch SDK")
                ProgressIndicator() // progress spinney
                BoxedText("API Token:", myApiToken, "User Identifier:", myUserIdentifier)
            } else {
                CenterHeadlineText("TapResearch SDK Ready")
                BoxedText("API Token:", myApiToken, "User Identifier:", myUserIdentifier)
                SurveyWallPreviewTiles(
                    surveysStateFlow = surveysStateFlow,
                ) { surveyId ->
                    TapResearch.showSurveyForPlacement(myPlacementTag, surveyId) { error ->
                        showToast(context,error.description)
                    }
                }
            }
        }
    }

    @Composable
    fun SurveyWallPreviewTiles(surveysStateFlow: StateFlow<SurveysState>, onItemClicked: (itemId: String) -> Unit) {
        Column {

            val surveysState = surveysStateFlow.collectAsState()
            val surveys = surveysState.value.surveys

            if (surveys.isNotEmpty()) {
                val rows = kotlin.math.ceil(surveys.size.toDouble() / SurveyTileConfig.SWP_NUM_COLUMNS).toInt()  // 2 columns
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .statusBarsPadding()
                        .navigationBarsPadding(),
                ) {

                    items(rows) { row ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.Center,
                        ) {
                            repeat(SurveyTileConfig.SWP_NUM_COLUMNS) { col ->
                                val index = row * SurveyTileConfig.SWP_NUM_COLUMNS + col
                                if (index < surveys.size) {
                                    SurveyTile(
                                        survey = surveys[index],
                                        modifier = Modifier
                                            .padding(3.dp)
                                            .clickable {
                                                surveys[index].surveyId?.let { surveyId ->
                                                    onItemClicked(surveyId)
                                                }
                                            },
                                    )
                                }
                            }
                        }
                    }
                }
            } else {
                CenterFullScreenText("No preview surveys available. Please try again.")
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

data class SurveysState(
    val surveys: List<TRSurvey> = emptyList(),
)

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