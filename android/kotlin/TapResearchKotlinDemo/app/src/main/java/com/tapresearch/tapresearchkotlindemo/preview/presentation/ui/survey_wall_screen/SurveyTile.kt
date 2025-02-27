package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredHeight
import androidx.compose.foundation.layout.requiredWidth
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccessTime
import androidx.compose.material.icons.outlined.Bolt
import androidx.compose.material.icons.outlined.CurrencyBitcoin
import androidx.compose.material.icons.outlined.Diamond
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.WallPreviewConfig.GREEN_COLOR
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.WallPreviewConfig.PURPLE_COLOR
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.animations.FireImage
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.animations.PulsingHeartImage
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.animations.SwayingStarImage
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme
import com.tapresearch.tapsdk.models.TRSurvey

@Preview
@Composable
fun SurveyTilePreview() {
    val survey = TRSurvey(
        surveyId = "mysurveyid-aaaaa",
        lengthInMinutes = 1,
        rewardAmount = 18f,
        currencyName = "tokens",
        isSale = true,
        saleEndDate = "2026-01-29T21:14:00.000Z",
        saleMultiplier = 2.5f,
        preSaleRewardAmount = 7f,
        isHotTile = true,
    )
    TapResearchKotlinDemoTheme {
        Surface {
            Column {
                SurveyTile(survey, Modifier)
            }
        }
    }
}

@Composable
fun SurveyTile(
                survey: TRSurvey,
                modifier: Modifier) {
    ElevatedCard(
        elevation = CardDefaults.cardElevation(
            defaultElevation = 6.dp
        ),
        modifier = modifier
            .size(width = WallPreviewConfig.CARD_WIDTH.dp, height = WallPreviewConfig.CARD_HEIGHT.dp)
            .requiredWidth(WallPreviewConfig.CARD_WIDTH.dp)
            .requiredHeight(WallPreviewConfig.CARD_HEIGHT.dp)
    ) {
        Column {

            if (survey.isHotTile == true) {

                Row(Modifier.background(Color.White)) {
                    Image(
                        imageVector = Icons.Outlined.AccessTime,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(3.dp)
                            .size(16.dp)
                    )
                    Text(
                        modifier = Modifier
                            .padding(0.dp, 3.dp, 0.dp, 0.dp)
                            .weight(1f),
                        text = survey.lengthInMinutes.toString(),
                        style = MaterialTheme.typography.labelSmall,
                    )
                    Text(
                        modifier = Modifier
                            .padding(0.dp, 3.dp, 0.dp, 0.dp),
                        text = "HOT!",
                        style = MaterialTheme.typography.labelSmall,
                    )

                    FireImage()
                }
            } else {
                Row(
                    Modifier
                        .background(Color.White)
                        .fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                    Image(
                        imageVector = Icons.Outlined.AccessTime,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(3.dp)
                            .size(16.dp)
                    )
                    Text(
                        modifier = Modifier
                            .padding(0.dp, 3.dp, 0.dp, 0.dp),
                        text = survey.lengthInMinutes.toString(),
                        style = MaterialTheme.typography.labelSmall,
                    )
                }
            }

            Box() {

                if (survey.isHotTile == true) {

                    PulsingHeartImage(
                        modifier = Modifier
                            .padding(6.dp, 7.dp, 0.dp, 0.dp)
                            .size(16.dp)
                    )
                    Image(
                        colorFilter = ColorFilter.tint(PURPLE_COLOR),
                        imageVector = Icons.Outlined.Diamond,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(15.dp, 0.dp, 0.dp, 7.dp)
                            .size(16.dp)
                            .align(Alignment.BottomStart)
                    )
                    Image(
                        colorFilter = ColorFilter.tint(PURPLE_COLOR),
                        imageVector = Icons.Outlined.CurrencyBitcoin,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(0.dp, 0.dp, 20.dp, 3.dp)
                            .size(16.dp)
                            .align(Alignment.BottomEnd)
                    )
                    SwayingStarImage(modifier = Modifier
                        .padding(0.dp, 0.dp, 2.dp, 28.dp)
                        .size(16.dp)
                        .align(Alignment.BottomEnd))
                    Image(
                        colorFilter = ColorFilter.tint(PURPLE_COLOR),
                        imageVector = Icons.Outlined.Bolt,
                        contentDescription = null,
                        modifier = Modifier
                            .padding(0.dp, 16.dp, 18.dp, 0.dp)
                            .size(16.dp)
                            .align(Alignment.TopEnd)
                    )
                }

                Canvas(modifier = Modifier.fillMaxSize()) {
                    drawCircle(
                        color = if (survey.isHotTile == true) PURPLE_COLOR
                                else GREEN_COLOR,
                        radius = size.minDimension / 2.50f,
                    )
                }

                Column(modifier = Modifier.align(Alignment.Center)) {
                    survey.preSaleRewardAmount?.let {
                        if (it > 0) {
                            Text(
                                //fontWeight = FontWeight.Bold,
                                color = Color.White,
                                //style = MaterialTheme.typography.titleSmall.plus(TextStyle(textDecoration = TextDecoration.LineThrough)),
                                style = TextStyle(textDecoration = TextDecoration.LineThrough),
                                text = it.toInt().toString(),
                                modifier = Modifier
                                    //.padding(3.dp)
                                    .align(Alignment.CenterHorizontally),
                            )
                        }
                    }

                    Text(
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        style = MaterialTheme.typography.headlineMedium,
                        text = survey.rewardAmount?.toInt().toString(),
                        modifier = Modifier
                            //.padding(3.dp)
                            .align(Alignment.CenterHorizontally),
                    )
                    Text(
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        style = MaterialTheme.typography.titleSmall,
                        text = survey.currencyName?:"tokens",
                        modifier = Modifier
                            //.padding(3.dp)
                            .align(Alignment.CenterHorizontally),
                    )
                }
            }
        }
    }
}

