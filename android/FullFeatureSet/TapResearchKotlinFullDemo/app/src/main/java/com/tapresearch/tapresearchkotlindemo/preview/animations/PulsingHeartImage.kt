package com.tapresearch.tapresearchkotlindemo.preview.animations

import androidx.compose.animation.animateColor
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.material.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import com.tapresearch.android.surveywallpreview.ui.SurveyTileConfig

@Composable
fun PulsingHeartImage(modifier: Modifier) {
    // Creates an [InfiniteTransition] instance for managing child animations.
    val infiniteTransition = rememberInfiniteTransition()

    // Creates a child animation of float type as a part of the [InfiniteTransition].
    val scale by
    infiniteTransition.animateFloat(
        initialValue = 0.1f,
        targetValue = 1.35f,
        animationSpec =
        infiniteRepeatable(
            // Infinitely repeating a 1000ms tween animation using default easing curve.
            animation = tween(2000),
            // After each iteration of the animation (i.e. every 1000ms), the animation
            // will
            // start again from the [initialValue] defined above.
            // This is the default [RepeatMode]. See [RepeatMode.Reverse] below for an
            // alternative.
            repeatMode = RepeatMode.Restart
        )
    )

    // Creates a Color animation as a part of the [InfiniteTransition].
    val color by
    infiniteTransition.animateColor(
        initialValue = Color.Red,
        targetValue = SurveyTileConfig.PURPLE_COLOR,
        animationSpec =
        infiniteRepeatable(
            // Linearly interpolate between initialValue and targetValue every 1000ms.
            animation = tween(1000, easing = LinearEasing),
            // Once [TargetValue] is reached, starts the next iteration in reverse (i.e.
            // from
            // TargetValue to InitialValue). Then again from InitialValue to
            // TargetValue. This
            // [RepeatMode] ensures that the animation value is *always continuous*.
            repeatMode = RepeatMode.Reverse
        )
    )

    Box(modifier.wrapContentWidth()) {
        Icon(
            Icons.Filled.Favorite,
            contentDescription = null,
            modifier =
            modifier.align(Alignment.Center).graphicsLayer(scaleX = scale, scaleY = scale),
            tint = color
        )
    }
}
