package com.tapresearch.tapresearchkotlindemo.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.Divider
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme

@Composable
fun MainUi(
    openPlacement: (placementTag: String) -> Unit,
    onSetUserIdentifier: (identifier: String) -> Unit,
    buttonOptions: List<String>,
    sendUserAttributes: () -> Unit,
    showWallPreview: () -> Unit,
    onGrantBoostClicked: (String) -> Unit,
) {
    TapResearchKotlinDemoTheme {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
        ) {
            Text(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp),
                text = "Available Placement",
            )

            for (option in buttonOptions) {
                Button(
                    onClick = { openPlacement(option) },
                    modifier = Modifier.padding(5.dp),
                ) {
                    Text(text = option)
                }
            }

            Divider(modifier = Modifier
                .fillMaxWidth()
                .padding(5.dp), color = Color.LightGray)

            SetUserIdDemo(onSetUserIdentifier)

            Button(
                onClick = { sendUserAttributes() },
                modifier = Modifier.padding(5.dp),
            ) {
                Text(text = "Send User Attributes")
            }

            GrantBoostDemo(onGrantBoostClicked)

            Button(
                onClick = { showWallPreview() },
                modifier = Modifier.padding(5.dp),
            ) {
                Text(text = "Survey Wall Preview Demo")
            }
        }
    }
}

@Preview
@Composable
fun MainDemoUiPreview() {
    TapResearchKotlinDemoTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background,
        ) {
            MainUi(
                openPlacement = {},
                onSetUserIdentifier = {},
                buttonOptions = listOf("home-screen", "earn-center", "awesome-zone",),
                sendUserAttributes = {},
                showWallPreview = {},
                onGrantBoostClicked = {},
            )
        }
    }
}

@Composable
private fun GrantBoostDemo(onGrantBoostDemoButtonPressed: (String) -> Unit) {
    val keyboardController = LocalSoftwareKeyboardController.current
    val newTextValue =
        remember { mutableStateOf(TextFieldValue("")) }
    TextField(
        newTextValue.value,
        onValueChange = {
            newTextValue.value = it
        },
        placeholder = { Text("Enter Grant Boost Tag") },
        label = { Text("Grant Boost Demo (e.g. boost-3x-1d)") },
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp, 0.dp, 8.dp, 4.dp),
        singleLine = true,
        leadingIcon = {
            if (newTextValue.value.text.isNotEmpty())
                IconButton(onClick =
                    {
                        newTextValue.value = TextFieldValue("")
                        keyboardController?.hide()
                    }
                ) {
                    Icon(
                        imageVector = Icons.Default.Clear,
                        contentDescription = "Clear",
                    )
                }
        },
        trailingIcon = {
            if (newTextValue.value.text.trim().isNotBlank())
                IconButton(
                    onClick = {
                        onGrantBoostDemoButtonPressed(newTextValue.value.text)
                        newTextValue.value = TextFieldValue("")
                    }
                ) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = "Set Boost Tag",
                        tint = Color.Magenta
                    )
                }
        }
    )
}

@Composable
private fun SetUserIdDemo(onSetUserIdButtonPressed: (String) -> Unit) {
    val keyboardController = LocalSoftwareKeyboardController.current
    val newTextValue =
        remember { mutableStateOf(TextFieldValue("")) }
    TextField(
        newTextValue.value,
        onValueChange = {
            newTextValue.value = it
        },
        placeholder = { Text("Enter New User Identifier") },
        label = { Text("Set New User Identifier") },
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp, 0.dp, 8.dp, 4.dp),
        singleLine = true,
        leadingIcon = {
            if (newTextValue.value.text.isNotEmpty())
                IconButton(onClick =
                    {
                        newTextValue.value = TextFieldValue("")
                        keyboardController?.hide()
                    }
                ) {
                    Icon(
                        imageVector = Icons.Default.Clear,
                        contentDescription = "Clear",
                    )
                }
        },
        trailingIcon = {
            if (newTextValue.value.text.trim().isNotBlank())
                IconButton(
                    onClick = {
                        onSetUserIdButtonPressed(newTextValue.value.text)
                        newTextValue.value = TextFieldValue("")
                    }
                ) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = "Set User Identifier",
                        tint = Color.Magenta
                    )
                }
        }
    )
}

@Preview
@Composable
fun GrantBoostDemoPreview() {
    TapResearchKotlinDemoTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background,
        ) {
            Row {
                GrantBoostDemo {  }
            }
        }
    }
}