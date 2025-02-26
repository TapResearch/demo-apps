package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui

import android.content.res.Configuration
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationRail
import androidx.compose.material3.NavigationRailItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.Screen
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme

@Composable
fun AppNavRail(
    currentRoute: String,
    navigateToHome: () -> Unit,
    modifier: Modifier = Modifier
) {
    NavigationRail(
        header = {
            Icon(
                imageVector = Icons.Filled.Home,
                null,
                Modifier.padding(vertical = 12.dp),
                tint = MaterialTheme.colorScheme.primary
            )
        },
        modifier = modifier
    ) {
        Spacer(Modifier.weight(1f))
        NavigationRailItem(
            selected = currentRoute == Screen.HomeScreen.route,
            onClick = navigateToHome,
            //icon = { Icon(Icons.Filled.Home, stringResource(R.string.home_title)) },
            //label = { Text(stringResource(R.string.home_title)) },
            icon = { Icon(Icons.Filled.Home, "Survey Wall") },
            label = { Text("Survey Wall") },
            alwaysShowLabel = false
        )
        Spacer(Modifier.weight(1f))
    }
}

@Preview("Drawer contents")
@Preview("Drawer contents (dark)", uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
fun PreviewAppNavRail() {
    TapResearchKotlinDemoTheme {
        AppNavRail(
            currentRoute = Screen.HomeScreen.route,
            navigateToHome = {},
        )
    }
}
