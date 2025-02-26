package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen

import android.annotation.SuppressLint
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.staggeredgrid.LazyStaggeredGridState
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CardGiftcard
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.TopAppBarScrollBehavior
import androidx.compose.material3.rememberTopAppBarState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tapresearch.kotlinsdk.preview.domain.use_case.get_surveys.SurveysState
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.TheExpandableAppBar
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.ErrorScreen
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.LoadingScreen
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.Constants.TOP_BAR_HEIGHT
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.animations.AnimatedSurveyTile
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.animations.HotBoostRow
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme
import com.tapresearch.tapsdk.models.TRReward
import com.tapresearch.tapsdk.models.TRSurvey
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@SuppressLint("CoroutineCreationDuringComposition")
@OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterialApi::class)
@Composable
private fun WallPreviewScreen(onGetSurveys: () -> Unit, onRefresh: () -> Unit, surveyState: StateFlow<SurveysState>, rewardsState: StateFlow<RewardsState>, onItemClicked: (itemId: String) -> Unit, lazyStaggeredGridState: LazyStaggeredGridState, topAppBarScrollBehavior: TopAppBarScrollBehavior, modifier: Modifier = Modifier) {

    var isRefreshing by remember { mutableStateOf(false) }
    val pullRefreshState = rememberPullRefreshState(
        refreshing = isRefreshing,
        onRefresh = {
            isRefreshing = true
            onRefresh()
        },
    )
    val myRewards = rewardsState.collectAsState()
    val mySurveys = surveyState.collectAsState()

    val coroutineScope = rememberCoroutineScope()
    if (myRewards.value.rewards.isNotEmpty()) {
        coroutineScope.launch {
            lazyStaggeredGridState.scrollToItem(index = 0)
            topAppBarScrollBehavior.state.heightOffset = 0f
        }
    }

    if (mySurveys.value.isLoading) {
        LoadingScreen()
    } else if (mySurveys.value.error.isNotEmpty()) {
        isRefreshing = false
        ErrorScreen(
            errorText = mySurveys.value.error,
            retryAction = { onGetSurveys() },
        )
    } else {
        isRefreshing = false
        // Box is needed for pull-to-refresh
        Box(
            modifier = Modifier
                .pullRefresh(pullRefreshState)
                .statusBarsPadding()
                .padding(
                    0.dp,
                    TOP_BAR_HEIGHT.dp,
                    0.dp,
                    0.dp,
                ),  // actionbar (48) + status bar (24) = 72
        ) {
            SurveysColumn(mySurveys.value.surveys, myRewards.value.rewards, onItemClicked)
            PullRefreshIndicator(
                refreshing = isRefreshing,
                state = pullRefreshState,
                modifier = Modifier.align(Alignment.TopCenter),
            )
        } //End Column
    }
}

@Composable
private fun SurveysColumn(surveys: List<TRSurvey>, rewards: List<TRReward>, onItemClicked: (itemId: String) -> Unit) {
    Column {

        if (surveys.isNotEmpty()) {

            // hard-code some fake data
            surveys.first().isHotTile = true
            surveys.first().preSaleRewardAmount = surveys.first().rewardAmount?.div(
                2,
            )
            surveys.first().saleMultiplier = 2.5f
            surveys.first().saleEndDate = "2026-01-29T21:14:00.000Z"
            surveys.first().isSale = true

            if (surveys.first().isSale == true) {
                surveys.first().saleMultiplier?.let { multiplier ->
                    if (multiplier > 0) {
                        HotBoostRow(multiplier = multiplier, saleEndDate = surveys.first().saleEndDate)
                        Spacer(Modifier.height(10.dp))
                    }
                }
            }

            val numColumns = 2
            val rows = kotlin.math.ceil(surveys.size.toDouble() / numColumns).toInt()  // 2 columns
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .statusBarsPadding()
                    .navigationBarsPadding(),
            ) {

                item {
                    if (rewards.isNotEmpty()) {
                        Column {
                            for (r in rewards) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(8.dp),
                                    horizontalArrangement = Arrangement.Center,
                                ) {
                                    Image(
                                        imageVector = Icons.Outlined.CardGiftcard,
                                        contentDescription = null,
                                        modifier = Modifier.size(24.dp),
                                    )
                                    Text(
                                        text = "${r.rewardAmount} ${r.currencyName}",
                                        style = MaterialTheme.typography.titleMedium,
                                        modifier = Modifier
                                            .padding(8.dp, 0.dp, 0.dp, 0.dp)
                                            .weight(
                                                1f,
                                            ),
                                    )
                                }
                            }
                        }
                    }
                }

                items(rows) { row ->
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Center,
                    ) {
                        repeat(2) { col ->
                            val index = row * numColumns + col
                            if (index < surveys.size) {
                                AnimatedSurveyTile(
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
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WallPreviewScreenWithAppBar(
    isExpandedScreen: Boolean,
    openDrawer: () -> Unit,
    onGetSurveys: () -> Unit,
    onRefresh: () -> Unit,
    rewardsState: StateFlow<RewardsState>,
    surveyState: StateFlow<SurveysState>,
    onItemClicked: (itemId: String) -> Unit,
    lazyStaggeredGridState: LazyStaggeredGridState,
    modifier: Modifier = Modifier,
) {
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background,
    ) {
        val scrollBehavior = TopAppBarDefaults.enterAlwaysScrollBehavior(rememberTopAppBarState())

        Scaffold(
            modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
            topBar = {
                TheExpandableAppBar(
                    title = "Survey Wall",
                    scrollBehavior = scrollBehavior,
                    isExpandedScreen = isExpandedScreen,
                    openDrawer = openDrawer,
                )
            },
        ) { innerPadding ->
            val screenModifier = Modifier.padding(innerPadding)
            WallPreviewScreen(
                onItemClicked = onItemClicked,
                modifier = screenModifier,
                onGetSurveys = onGetSurveys,
                onRefresh = onRefresh,
                surveyState = surveyState,
                rewardsState = rewardsState,
                lazyStaggeredGridState = lazyStaggeredGridState,
                topAppBarScrollBehavior = scrollBehavior,
            )
        }

    }
}

@Preview
@Composable
fun SurveyColumnPreview() {

    val s = TRSurvey(
        surveyId = "aaaa",
        lengthInMinutes = 2,
        rewardAmount = 30f,
        currencyName = "Tokens",
        isSale = true,
        saleEndDate = "2026-01-29T21:14:00.000Z",
        saleMultiplier = 2.5f,
        preSaleRewardAmount = 15f,
        isHotTile = true,
    )
    val s0 = TRSurvey(
        surveyId = "asdfasfd",
        lengthInMinutes = 2,
        rewardAmount = 30f,
        currencyName = "Tokens",
        isSale = true,
        saleEndDate = "2026-01-29T21:14:00.000Z",
        saleMultiplier = 2.5f,
        preSaleRewardAmount = 15f,
        isHotTile = false,
    )
    val s1 = TRSurvey(
        surveyId = "2345234535",
        lengthInMinutes = 11,
        rewardAmount = 60f,
        currencyName = "Tokens",
        isSale = true,
        saleEndDate = "2026-01-29T21:14:00.000Z",
        saleMultiplier = 2.5f,
        preSaleRewardAmount = 28f,
        isHotTile = false,
    )
    val s2 = TRSurvey(
        surveyId = "aaerqweraa",
        lengthInMinutes = 1,
        rewardAmount = 50f,
        currencyName = "Tokens",
        isSale = true,
        saleEndDate = "2026-01-29T21:14:00.000Z",
        saleMultiplier = 2.5f,
        preSaleRewardAmount = 25f,
        isHotTile = false,
    )
    val s3 = TRSurvey(
        surveyId = "rtyurtyu",
        lengthInMinutes = 3,
        rewardAmount = 100f,
        currencyName = "Tokens",
        isSale = true,
        saleEndDate = "2026-01-29T21:14:00.000Z",
        saleMultiplier = 2.5f,
        preSaleRewardAmount = 50f,
        isHotTile = false,
    )
    val testSurveys = listOf(s, s0, s1, s2, s3)
    val reward = TRReward(
        transactionIdentifier = "cvbsdfsdf",
        placementIdentifier = "23452345",
        currencyName = "Tokens",
        rewardAmount = 899f,
        payoutEventType = "a payout event type",
        placementTag = "MyPlacementTag",
    )
    val reward0 = TRReward(
        transactionIdentifier = "ertyerty",
        placementIdentifier = "678678",
        currencyName = "Tokens",
        rewardAmount = 100f,
        payoutEventType = "a payout event type",
        placementTag = "MyPlacementTag",
    )
    val rewardList = listOf(reward, reward0)
    TapResearchKotlinDemoTheme {
        Surface {
            SurveysColumn(surveys = testSurveys, rewards = rewardList) {

            }
        }
    }
}
