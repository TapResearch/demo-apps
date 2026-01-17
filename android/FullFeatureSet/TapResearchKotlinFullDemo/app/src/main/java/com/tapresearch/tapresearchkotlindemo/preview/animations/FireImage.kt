package com.tapresearch.tapresearchkotlindemo.preview.animations

import androidx.compose.animation.animateColor
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.twotone.LocalFireDepartment
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.unit.dp

@Composable
fun FireImage() {
    val infiniteFireTransition = rememberInfiniteTransition()
    val fireColor by
    infiniteFireTransition.animateColor(
        initialValue = Color.Red,
        targetValue = Color(255, 152, 0 ),
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
    Image(
        colorFilter = ColorFilter.tint(fireColor),
        imageVector = Icons.TwoTone.LocalFireDepartment,
        contentDescription = null,
        modifier = Modifier
            .padding(3.dp)
            .size(16.dp)
    )
}
