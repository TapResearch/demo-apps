package com.tapresearch.android.surveywallpreview.animations

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.animate
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen.SurveyTile
import com.tapresearch.android.surveywallpreview.ui.SurveyTileConfig
import com.tapresearch.tapsdk.models.TRSurvey
import kotlin.random.Random
import kotlin.random.nextInt


@Composable
fun AnimatedSurveyTile(survey: TRSurvey,
                       modifier: Modifier) {

    if (SurveyTileConfig.RANDOMIZE_PREVIEW_WALL_ANIMATIONS && Random.nextBoolean()) {
        var xRotation by remember {
            mutableStateOf(0f)
        }
        var yRotation by remember {
            mutableStateOf(0f)
        }

        LaunchedEffect(key1 = Unit, block = {
            if (Random.nextBoolean()) {
                animate(
                    Random.nextInt(20..250).toFloat(),
                    0f,
                    animationSpec = tween(1000, easing = LinearOutSlowInEasing),
                    block = { value, _ -> xRotation = value }
                )
            } else {
                animate(
                    Random.nextInt(20..250).toFloat(),
                    0f,
                    animationSpec = tween(1000, easing = LinearEasing),
                    block = { value, _ -> yRotation = value }
                )
            }
        })
        SurveyTile(
            survey = survey,
            modifier = modifier
                .graphicsLayer {
                    rotationX = xRotation
                    rotationY = yRotation
                }
        )
    } else {
        var show by remember { mutableStateOf(false) }

        AnimatedVisibility(
            visible = show,
            // By Default, `scaleIn` uses the center as its pivot point. When used with a vertical
            // expansion from the vertical center, the content will be growing from the center of
            // the vertically expanding layout.
            enter = scaleIn() + expandVertically(expandFrom = Alignment.CenterVertically),
            // By Default, `scaleOut` uses the center as its pivot point. When used with an
            // ExitTransition that shrinks towards the center, the content will be shrinking both
            // in terms of scale and layout size towards the center.
            exit = scaleOut() + shrinkVertically(shrinkTowards = Alignment.CenterVertically),
        ) {
            SurveyTile(survey = survey, modifier = modifier)
        }

        LaunchedEffect(
            key1 = Unit,
            block = {
                show = true
            },
        )
    }
}
