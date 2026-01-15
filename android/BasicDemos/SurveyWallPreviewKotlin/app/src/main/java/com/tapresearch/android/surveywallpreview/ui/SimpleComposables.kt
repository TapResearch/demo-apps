import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Divider
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tapresearch.android.surveywallpreview.ui.theme.SurveyWallPreviewTheme


@Composable
fun BoxedText(line1: String, line2: String,
              line3: String, line4: String,
              modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .border(1.dp, Color.Black, RoundedCornerShape(4.dp))
            .background(Color.LightGray, RoundedCornerShape(4.dp))
            .padding(10.dp) // Padding inside the border
    ) {
        Column(
            modifier = modifier
                .fillMaxWidth(),
            horizontalAlignment = Alignment.Start,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = line1,
                style = MaterialTheme.typography.titleMedium,
            )
            Text(
                text = line2,
                style = MaterialTheme.typography.titleMedium,
            )
            Divider(modifier = Modifier
                .fillMaxWidth()
                .padding(5.dp), color = Color.Black)
            Text(
                text = line3,
                style = MaterialTheme.typography.titleMedium,
            )
            Text(
                text = line4,
                style = MaterialTheme.typography.titleMedium,
            )
        }
    }
}

@Preview
@Composable
fun BoxedTextPreview() {
    SurveyWallPreviewTheme {
        Surface {
            BoxedText("line one: ", "line two", "line three", "line four")
        }
    }
}

@Composable
fun CenterHeadlineText(text: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.headlineMedium,
        )
    }
}

@Composable
fun CenterMediumText(text: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            modifier = modifier.padding(8.dp),
            text = text,
            style = MaterialTheme.typography.titleMedium,
        )
    }
}

@Composable
fun CenterFullScreenText(text: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.titleMedium,
        )
    }
}

@Preview
@Composable
fun CenterFullScreenTextPreview() {
    SurveyWallPreviewTheme {
        Surface {
            CenterFullScreenText("center fullscreen text")
        }
    }
}

@Preview
@Composable
fun CenterHeadlineTextPreview() {
    SurveyWallPreviewTheme {
        Surface {
            CenterHeadlineText("center headline text")
        }
    }
}

@Composable
fun BodyText(text: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}

@Composable
fun ProgressIndicator(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CircularProgressIndicator(
            modifier = modifier.width(64.dp),
            color = MaterialTheme.colorScheme.secondary,
            trackColor = MaterialTheme.colorScheme.surfaceVariant,
        )
        Spacer(modifier = Modifier.padding(16.dp))
        Spacer(modifier = Modifier.padding(16.dp))
    }
}
