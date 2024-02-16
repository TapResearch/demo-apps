package com.tapresearch.tapresearchkotlindemo.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme

@OptIn(ExperimentalComposeUiApi::class, ExperimentalMaterial3Api::class)
@Composable
fun MainUi(
    openPlacement: (placementTag: String) -> Unit,
    onSetUserIdentifier: (identifier: String) -> Unit,
    buttonOptions: List<String>,
    sendUserAttributes: () -> Unit,
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

            val showTextField = remember { mutableStateOf(false) }
            val userIdentifier = remember { mutableStateOf("") }
            val keyboardController = LocalSoftwareKeyboardController.current

            Button(
                onClick = { showTextField.value = !showTextField.value },
                modifier = Modifier.padding(5.dp),
            ) {
                Text(text = if (showTextField.value) "Hide User Identifier Input" else "Set User Identifier")
            }

            Button(
                onClick = { sendUserAttributes() },
                modifier = Modifier.padding(5.dp),
            ) {
                Text(text = "Send User Attributes")
            }

            if (showTextField.value) {
                TextField(
                    value = userIdentifier.value,
                    onValueChange = { userIdentifier.value = it },
                    label = { Text("Set User Identifier") },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(5.dp),
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Text,
                        imeAction = ImeAction.Done,
                    ),
                    keyboardActions = KeyboardActions(
                        onDone = {
                            keyboardController?.hide()
                            onSetUserIdentifier(userIdentifier.value)
                        },
                    ),
                )
            }
        }
    }
}
