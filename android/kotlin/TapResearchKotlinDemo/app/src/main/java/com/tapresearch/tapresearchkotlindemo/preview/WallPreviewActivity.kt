package com.tapresearch.tapresearchkotlindemo.preview

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.windowsizeclass.ExperimentalMaterial3WindowSizeClassApi
import androidx.compose.material3.windowsizeclass.calculateWindowSizeClass
import com.tapresearch.tapresearchkotlindemo.preview.common.GlobalData
import com.tapresearch.tapresearchkotlindemo.preview.presentation.WallPreviewApp
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WallPreviewActivity : ComponentActivity() {
    @OptIn(ExperimentalMaterial3WindowSizeClassApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            GlobalData.currentPlacementTag = "earn-center"
            val widthSizeClass = calculateWindowSizeClass(this).widthSizeClass
            WallPreviewApp(widthSizeClass = widthSizeClass)
        }
    }
}
