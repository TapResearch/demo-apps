package com.tapresearch.tapresearchkotlindemo.preview.presentation.ui

import androidx.compose.animation.Crossfade
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.outlined.Menu
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.TopAppBarScrollBehavior
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.platform.LocalSoftwareKeyboardController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TheExpandableAppBar(scrollBehavior: TopAppBarScrollBehavior,
                        isExpandedScreen: Boolean,
                        openDrawer: () -> Unit,
                        title: String
                       ) {
    val expandedInitially = false
    val (expanded, onExpandedChanged) = remember {
        mutableStateOf(expandedInitially)
    }

    Crossfade(targetState = expanded) { isSearchFieldVisible ->
        when (isSearchFieldVisible) {
            true -> MySearchBar(onExpandedChanged)

            false -> MyTopAppBar(
                title = title,
                isExpandedScreen = isExpandedScreen,
                scrollBehavior,
                openDrawer = openDrawer)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun MyTopAppBar(
                title: String,
                isExpandedScreen: Boolean,
                scrollBehavior: TopAppBarScrollBehavior,
                openDrawer: () -> Unit) {

    TopAppBar(
        scrollBehavior = scrollBehavior,
        title = {
            Text(text = title)
        },
        navigationIcon = {
            if (!isExpandedScreen) {
                IconButton(onClick = openDrawer) {
                    Icon(
                        imageVector = Icons.Outlined.Menu,
                        contentDescription = "Open Drawer",
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
            titleContentColor = MaterialTheme.colorScheme.onSurfaceVariant
        ),
        actions = {

            IconButton(onClick = {
                // do something
            }) {
                Icon(
                    imageVector = Icons.Default.ArrowDropDown,
                    contentDescription = "Options"
                )
            }
        }
    )
}

@Composable
private fun MySearchBar(
                onExpandedChanged: (Boolean) -> Unit,
) {
    val keyboard = LocalSoftwareKeyboardController.current
    var active by remember {
        mutableStateOf(true)
    }
    val textFieldFocusRequester = remember { FocusRequester() }
    SideEffect {
        textFieldFocusRequester.requestFocus()
    }
}
