package com.tapresearch.tapresearchkotlindemo.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.outlined.Done
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import com.tapresearch.tapresearchkotlindemo.ui.theme.TapResearchKotlinDemoTheme

@Composable
fun MainUi(
    userIdentifier: String,
    openPlacement: (placementTag: String) -> Unit,
    onSetUserIdentifier: (identifier: String) -> Unit,
    buttonOptions: List<String>,
    sendUserAttributes: () -> Unit,
    showWallPreview: () -> Unit,
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

            UserIdentifierRow(userIdentifier, onSetUserIdentifier)

            Button(
                onClick = { sendUserAttributes() },
                modifier = Modifier.padding(5.dp),
            ) {
                Text(text = "Send User Attributes")
            }

            Button(
                onClick = { showWallPreview() },
                modifier = Modifier.padding(5.dp),
            ) {
                Text(text = "Wall Preview Feature")
            }
        }
    }
}

@Composable
private fun UserIdentifierRow(initialUserId: String, onSaveUserId: (String) -> Unit) {
    val keyboardController = LocalSoftwareKeyboardController.current
    val newUserId = remember { mutableStateOf(TextFieldValue(initialUserId)) }
    val originalUserId = remember { mutableStateOf(TextFieldValue(initialUserId)) }

    TextField(
        newUserId.value,
        onValueChange = {
            newUserId.value = it
        },
        placeholder = { Text("Enter User Id") },
        label = { Text("Modify User Id") },
        modifier = Modifier
            .fillMaxWidth()
            .padding(5.dp, 0.dp, 5.dp, 0.dp),
        singleLine = true,
        leadingIcon = {
            if (newUserId.value.text != originalUserId.value.text && newUserId.value.text.isNotEmpty()) {
                IconButton(
                    onClick =
                        {
                            newUserId.value = TextFieldValue(originalUserId.value.text)
                            keyboardController?.hide()
                        }
                ) {
                    Icon(
                        imageVector = Icons.Default.Clear,
                        contentDescription = "Clear",
                    )
                }
            }
        },
        trailingIcon = {
            if (newUserId.value.text != originalUserId.value.text && newUserId.value.text.trim().isNotBlank()) {
                IconButton(
                    onClick = {
                        onSaveUserId(newUserId.value.text)
                        keyboardController?.hide()
                        originalUserId.value = newUserId.value
                    }
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Done,
                        contentDescription = "Save User Id",
                        tint = Color.Magenta
                    )
                }
            }
        }
    )
}
