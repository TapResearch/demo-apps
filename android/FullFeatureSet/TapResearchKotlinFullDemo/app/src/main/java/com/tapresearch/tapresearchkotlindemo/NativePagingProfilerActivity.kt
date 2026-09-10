package com.tapresearch.tapresearchkotlindemo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Checkbox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.tapresearch.tapsdk.TapResearch
import com.tapresearch.tapsdk.models.TRProfileAnswer
import com.tapresearch.tapsdk.models.TRQualification
import com.tapresearch.tapsdk.models.TRQualificationsResponse
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update
import androidx.compose.material3.HorizontalDivider as Divider

data class PagingQualificationAnswerState(
    val values: List<String> = emptyList(),
    val countryCode: String? = null
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PagingQualificationItem(
    qualification: TRQualification,
    state: PagingQualificationAnswerState,
    onStateChanged: (PagingQualificationAnswerState) -> Unit
) {
    Column(modifier = Modifier.padding(vertical = 8.dp)) {
        Text(
            text = qualification.questionText ?: "",
            style = MaterialTheme.typography.titleMedium
        )
        qualification.previousError?.let { error ->
            Text(
                text = error,
                style = MaterialTheme.typography.labelSmall,
                color = Color.Red,
                modifier = Modifier.padding(bottom = 4.dp)
            )
        }
        Text(
            text = "Type: ${qualification.answerType}",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.outline
        )

        when (qualification.answerType) {
            "single_select" -> {
                qualification.qualificationAnswers?.forEach { answer ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onStateChanged(PagingQualificationAnswerState(listOf(answer.preCode ?: ""))) }
                    ) {
                        RadioButton(
                            selected = state.values.contains(answer.preCode),
                            onClick = { onStateChanged(PagingQualificationAnswerState(listOf(answer.preCode ?: ""))) }
                        )
                        Text(text = answer.optionText ?: "")
                    }
                }
            }
            "multi_select" -> {
                qualification.qualificationAnswers?.forEach { answer ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                val current = state.values.toMutableList()
                                val code = answer.preCode ?: ""
                                if (current.contains(code)) current.remove(code) else current.add(code)
                                onStateChanged(state.copy(values = current))
                            }
                    ) {
                        Checkbox(
                            checked = state.values.contains(answer.preCode),
                            onCheckedChange = {
                                val current = state.values.toMutableList()
                                val code = answer.preCode ?: ""
                                if (it) current.add(code) else current.remove(code)
                                onStateChanged(state.copy(values = current))
                            }
                        )
                        Text(text = answer.optionText ?: "")
                    }
                }
            }
            "date", "zip_code", "text", "integer" -> {

                val keyboardType = when (qualification.answerType) {
                    "date", "integer" -> KeyboardType.Number
                    "zip_code" -> KeyboardType.NumberPassword
                    else -> KeyboardType.Text
                }
                TextField(
                    value = state.values.firstOrNull() ?: "",
                    onValueChange = {
                        if (it.isBlank()) {
                            onStateChanged(state.copy(values = emptyList()))
                        } else {
                            onStateChanged(state.copy(values = listOf(it)))
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
                    placeholder = { Text("Enter ${qualification.answerType}") }
                )
            }
            else -> {
                Text(text = "Unsupported answer type", color = MaterialTheme.colorScheme.error)
            }
        }
    }
}

class NativePagingProfilerActivity : ComponentActivity() {

    private val qualificationsState = MutableStateFlow<TRQualificationsResponse?>(null)
    private val isSubmittingState = MutableStateFlow(false)
    private lateinit var apiToken: String
    private lateinit var userIdentifier: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        apiToken = intent.getStringExtra("apiToken") ?: ""
        userIdentifier = intent.getStringExtra("userIdentifier") ?: ""
        fetchQualifications()

        setContent {
            val response = qualificationsState.collectAsState().value
            val isSubmitting = isSubmittingState.collectAsState().value
            val currentQualification = response?.qualifications?.firstOrNull()
            val answers = remember { mutableStateMapOf<Int, PagingQualificationAnswerState>() }

            MaterialTheme {
                Scaffold(
                    modifier = Modifier.fillMaxSize(),
                    bottomBar = {
                        if ((currentQualification != null) && !isSubmitting) {
                            Button(
                                onClick = { submitSingleAnswer(currentQualification, answers) },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                enabled = answers.containsKey(currentQualification.questionId)
                            ) {
                                Text("Submit Answer")
                            }
                        }
                    }
                ) { contentPadding ->
                    Surface(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(contentPadding),
                    ) {
                        if (isSubmitting) {
                            Column(
                                modifier = Modifier.fillMaxSize(),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Text(
                                    text = "Submitting Answer...",
                                    style = MaterialTheme.typography.headlineSmall
                                )
                            }
                        } else {
                            Column(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .verticalScroll(rememberScrollState())
                                    .padding(16.dp)
                            ) {
                                Text(
                                    text = "Paging Native Profiler",
                                    style = MaterialTheme.typography.headlineMedium
                                )
                                Text(
                                    text = "API Token: $apiToken",
                                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                    color = Color.Blue
                                )
                                Text(
                                    text = "User ID: $userIdentifier",
                                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                    color = Color.Blue
                                )

                                if (response?.error != null) {
                                    Text(
                                        text = response.error?.description ?: "Unknown error",
                                        style = MaterialTheme.typography.headlineSmall,
                                        color = Color.Red,
                                        modifier = Modifier.padding(top = 16.dp)
                                    )
                                } else if (response == null) {
                                    Text(text = "Loading...")
                                } else {
                                    Text(text = "Country: ${response.countryCode}, Locale: ${response.locale}")
                                    Text(text = "Is Profiled: ${response.isProfiled}")

                                    // Qualifications Submission Summary
                                    response.qualificationsResult?.let {
                                        Divider()
                                        Text(
                                            text = "Qualifications Submission Summary:",
                                            style = MaterialTheme.typography.titleMedium
                                        )
                                        it.acceptedCount?.let { acceptedCount ->
                                            Text(text = "Accepted Count: $acceptedCount")
                                        }
                                        it.invalidCount?.let { invalidCount ->
                                            Text(text = "Invalid Count: $invalidCount")
                                        }
                                        it.errors?.forEach { questionError ->
                                            Text(text = "Question Id: ${questionError.questionId} Error: ${questionError.error}")
                                        }
                                        Divider()
                                    }

                                    if (response.isProfiled == true) {
                                        Text(text = "No further qualification questions required. Go back and change the user identifier.")
                                    } else if (currentQualification != null) {
                                        Text(
                                            text = "Answer the following question:",
                                            modifier = Modifier.padding(top = 16.dp)
                                        )
                                        PagingQualificationItem(
                                            qualification = currentQualification,
                                            state = answers[currentQualification.questionId ?: -1] ?: PagingQualificationAnswerState(),
                                            onStateChanged = { newState ->
                                                currentQualification.questionId?.let { id ->
                                                    if (newState.values.isEmpty() && (newState.countryCode == null)) {
                                                        answers.remove(id)
                                                    } else {
                                                        answers[id] = newState
                                                    }
                                                }
                                            }
                                        )
                                    } else {
                                        Text(text = "No more questions for now.")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private fun fetchQualifications() {
        TapResearch.getProfilingQualifications(apiToken, userIdentifier) { response ->
            qualificationsState.update { response }
        }
    }

    private fun submitSingleAnswer(qualification: TRQualification, answers: Map<Int, PagingQualificationAnswerState>) {
        val id = qualification.questionId ?: return
        val state = answers[id] ?: return
        
        isSubmittingState.update { true }
        val submissions = listOf(TRProfileAnswer(id, state.values))
        
        TapResearch.sendProfilingQualifications(apiToken, userIdentifier, submissions) { response ->
            isSubmittingState.update { false }
            qualificationsState.update { response }
        }
    }
}
