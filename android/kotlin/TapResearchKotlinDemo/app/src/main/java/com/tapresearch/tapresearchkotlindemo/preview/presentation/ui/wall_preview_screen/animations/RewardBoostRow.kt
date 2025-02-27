package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen.animations

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen.WallPreviewConfig
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen.Util
import kotlinx.coroutines.delay

@Composable
fun HotBoostRow(multiplier: Float, saleEndDate: String?) {
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
        // Content that needs to appear/disappear goes here:
        Row(
            modifier = Modifier
                .background(WallPreviewConfig.PURPLE_COLOR)
                .fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
        ) {

            Text(
                modifier = Modifier.padding(4.dp),
                text = "${multiplier}x Reward Boost!",
                fontWeight = FontWeight.Bold,
                color = Color.White,
                style = MaterialTheme.typography.titleSmall,
            )

            Text(
                modifier = Modifier.padding(4.dp),
                text = Util.endsIn(saleEndDate),
                color = Color.White,
                style = MaterialTheme.typography.titleSmall,
            )
        }
    }

    LaunchedEffect(
        key1 = Unit,
        block = {
            delay(1100)
            show = true
        },
    )
}
