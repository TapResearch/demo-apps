package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui

import android.widget.Toast
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.Screen
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen.WallPreviewScreenWithAppBar
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.wall_preview_screen.WallPreviewViewModel

@Composable
fun WallPreviewNavHost(
    navigationActions: WallPreviewNavigationActions,
    isExpandedScreen: Boolean,
    modifier: Modifier = Modifier,
    navController: NavHostController,
    openDrawer: () -> Unit = {},
    startDestination: String = Screen.HomeScreen.route,
) {

    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Screen.HomeScreen.route) {
            val context = LocalContext.current
            val viewModel = hiltViewModel<WallPreviewViewModel>()
            WallPreviewScreenWithAppBar(
                isExpandedScreen = isExpandedScreen,
                openDrawer = openDrawer,
                onGetSurveys = { viewModel.getSurveys() },
                onRefresh = { viewModel.getSurveys() },
                surveyState = viewModel.surveysState,
                rewardsState = viewModel.rewardsState,
                onItemClicked = { surveyId ->
                    viewModel.showSurveyForPlacement(surveyId) {error ->
                        Toast.makeText(context, error, Toast.LENGTH_SHORT).show()
                    }
                },
                lazyStaggeredGridState = viewModel.lazyStaggeredGridState
            )
        }
    }
}
