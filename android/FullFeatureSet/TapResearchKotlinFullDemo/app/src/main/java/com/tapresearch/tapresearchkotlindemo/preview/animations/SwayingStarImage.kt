package com.tapresearch.tapresearchkotlindemo.preview.animations

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import com.tapresearch.android.surveywallpreview.ui.SurveyTileConfig

@Composable
fun SwayingStarImage(modifier: Modifier) {
    val animationValue by rememberInfiniteTransition().animateFloat(
        initialValue = 25f,
        targetValue = -25f,
        animationSpec = infiniteRepeatable(

            animation = tween<Float>(
                durationMillis = 600,
                easing = LinearEasing
            ),
            repeatMode = RepeatMode.Reverse
        )
    )

    Image(
        colorFilter = ColorFilter.tint(SurveyTileConfig.PURPLE_COLOR),
        imageVector = Icons.Outlined.StarOutline,
        contentDescription = null,
        modifier = modifier
            .graphicsLayer(
                transformOrigin = TransformOrigin(
                    pivotFractionX = 0.5f,
                    pivotFractionY = 0.0f,
                ),
                rotationZ = animationValue
            )
    )

}
