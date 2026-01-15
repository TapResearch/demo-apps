package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common

sealed class Screen(val route: String) {
    object HomeScreen : Screen("home_screen")
}
