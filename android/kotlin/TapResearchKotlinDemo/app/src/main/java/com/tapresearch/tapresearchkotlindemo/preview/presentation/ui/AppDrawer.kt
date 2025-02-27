package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui

import android.content.res.Configuration
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalDrawerSheet
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.NavigationDrawerItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tapresearch.tapresearchkotlindemo.R
import com.tapresearch.tapresearchkotlindemo.preview.presentation.ui.common.Screen
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppDrawer(
    currentRoute: String,
    navigateToHome: () -> Unit,
    closeDrawer: () -> Unit,
    modifier: Modifier = Modifier
) {
    ModalDrawerSheet(modifier.fillMaxWidth(.8f)) {
        PreviewWallLogo(
            modifier = Modifier.padding(horizontal = 28.dp, vertical = 24.dp)
        )
        NavigationDrawerItem(
            label = { Text(stringResource(id = R.string.wall_preview_drawer_item_label)) },
            icon = { Icon(Icons.Filled.Home, null) },
            selected = currentRoute.startsWith(Screen.HomeScreen.route),
            onClick = { navigateToHome(); closeDrawer() },
            modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding)
        )
    }
}

@Composable
private fun PreviewWallLogo(modifier: Modifier = Modifier) {
    Row(modifier = modifier) {
        Icon(
            imageVector = Icons.Filled.Menu,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary
        )
        Spacer(Modifier.width(8.dp))
        Text(stringResource(id = R.string.wall_preview_drawer_title))
    }
}

@Preview("Drawer contents")
@Preview("Drawer contents (dark)", uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
fun PreviewLogo() {
    TapResearchKotlinDemoTheme {
        PreviewWallLogo()
    }
}

@Preview("Drawer contents")
@Preview("Drawer contents (dark)", uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
fun PreviewAppDrawer() {
    TapResearchKotlinDemoTheme {
        AppDrawer(
            currentRoute = Screen.HomeScreen.route,
            navigateToHome = {},
            closeDrawer = {},
        )
    }
}
