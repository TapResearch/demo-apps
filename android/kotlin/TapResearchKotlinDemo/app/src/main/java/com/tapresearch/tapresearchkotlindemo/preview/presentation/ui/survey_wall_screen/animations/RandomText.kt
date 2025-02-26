package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.survey_wall_screen.animations

import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun RandomText() {
    val shortText = "Hi"
    val longText = "Very long text\nthat spans across\nmultiple lines"
    var short by remember { mutableStateOf(true) }
    Box(
        modifier = Modifier.background(
            Color.Blue,
            RoundedCornerShape(15.dp),
        ).clickable { short = !short }.padding(20.dp).wrapContentSize().animateContentSize(),
    ) {
        Text(
            if (short) {
                shortText
            } else {
                longText
            },
            style = LocalTextStyle.current.copy(color = Color.White),
        )
    }
}
