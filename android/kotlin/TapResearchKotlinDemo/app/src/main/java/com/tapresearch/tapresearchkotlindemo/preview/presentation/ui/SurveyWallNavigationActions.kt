package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui

import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.Screen


/**
 * Models the navigation actions in the app.
 */
class SurveyWallNavigationActions(navController: NavHostController) {
    val navigateToHome: () -> Unit = {
        navController.navigate(Screen.HomeScreen.route) {
            // Pop up to the start destination of the graph to
            // avoid building up a large stack of destinations
            // on the back stack as users select items
            popUpTo(navController.graph.findStartDestination().id) {
                saveState = true
            }
            // Avoid multiple copies of the same destination when
            // re-selecting the same item
            launchSingleTop = true
            // Restore state when re-selecting a previously selected item
            restoreState = true
        }
    }
}
