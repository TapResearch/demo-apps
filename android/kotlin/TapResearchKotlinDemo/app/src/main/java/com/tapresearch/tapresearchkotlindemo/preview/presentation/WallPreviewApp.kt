package com.tapresearch.tapresearchkotlindemo.preview.presentation

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.add
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.systemBars
import androidx.compose.material3.DrawerState
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.rememberDrawerState
import androidx.compose.material3.windowsizeclass.WindowWidthSizeClass
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.AppDrawer
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.AppNavRail
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.SurveyWallNavHost
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.BackPressHandler
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.SurveyWallNavigationActions
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.Screen
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme
import kotlinx.coroutines.launch

@Composable
fun WallPreviewApp(
    widthSizeClass: WindowWidthSizeClass,
) {
    TapResearchKotlinDemoTheme {
        val navController = rememberNavController()
        val navigationActions = remember(navController) {
            SurveyWallNavigationActions(navController)
        }

        val coroutineScope = rememberCoroutineScope()

        val navBackStackEntry by navController.currentBackStackEntryAsState()
        val currentRoute =
            navBackStackEntry?.destination?.route ?: Screen.HomeScreen.route

        val isExpandedScreen = widthSizeClass == WindowWidthSizeClass.Expanded
        val sizeAwareDrawerState = rememberSizeAwareDrawerState(isExpandedScreen)

        if (sizeAwareDrawerState.isOpen) {
            BackPressHandler(onBackPressed = {
                coroutineScope.launch { sizeAwareDrawerState.close() }
            })
        }

        ModalNavigationDrawer(
            drawerContent = {
                AppDrawer(
                    currentRoute = currentRoute,
                    navigateToHome = {navigationActions.navigateToHome()},
                    closeDrawer = { coroutineScope.launch { sizeAwareDrawerState.close() } }
                )
            },
            drawerState = sizeAwareDrawerState,
            // Only enable opening the drawer via gestures if the screen is not expanded
            gesturesEnabled = !isExpandedScreen
                /*&& !currentRoute.startsWith(Screen.DetailsScreen.route)*/
        ) {
            Row {
                if (isExpandedScreen) {
                    AppNavRail(
                        currentRoute = currentRoute,
                        navigateToHome = {navigationActions.navigateToHome()},
                    )
                }
                SurveyWallNavHost(
                    startDestination = Screen.HomeScreen.route,
                    navigationActions = navigationActions,
                    isExpandedScreen = isExpandedScreen,
                    navController = navController,
                    openDrawer = { coroutineScope.launch{ sizeAwareDrawerState.open() } },
                )
            }
        }
    }
}

/**
 * Determine the drawer state to pass to the modal drawer.
 */
@Composable
private fun rememberSizeAwareDrawerState(isExpandedScreen: Boolean): DrawerState {
    val drawerState = rememberDrawerState(DrawerValue.Closed)

    return if (!isExpandedScreen) {
        // If we want to allow showing the drawer, we use a real, remembered drawer
        // state defined above
        drawerState
    } else {
        // If we don't want to allow the drawer to be shown, we provide a drawer state
        // that is locked closed. This is intentionally not remembered, because we
        // don't want to keep track of any changes and always keep it closed
        DrawerState(DrawerValue.Closed)
    }
}

/**
 * Determine the content padding to apply to the different screens of the app
 */
@Composable
fun rememberContentPaddingForScreen(
    additionalTop: Dp = 0.dp,
    excludeTop: Boolean = false
) =
    WindowInsets.systemBars
        .only(if (excludeTop) WindowInsetsSides.Bottom else WindowInsetsSides.Vertical)
        .add(WindowInsets(top = additionalTop))
        .asPaddingValues()
