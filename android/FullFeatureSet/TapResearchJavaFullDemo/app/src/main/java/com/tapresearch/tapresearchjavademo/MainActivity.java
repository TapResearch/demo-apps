package com.tapresearch.tapresearchjavademo;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;

import com.tapresearch.tapsdk.TapInitOptions;
import com.tapresearch.tapsdk.TapResearch;
import com.tapresearch.tapsdk.callback.TRContentCallback;
import com.tapresearch.tapsdk.models.TRError;
import com.tapresearch.tapsdk.models.TRPlacementDetails;
import com.tapresearch.tapsdk.models.TRReward;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;

import kotlinx.serialization.InternalSerializationApi;

@InternalSerializationApi
public class MainActivity extends AppCompatActivity {
    // Tag used for logging. Helps in identifying the source of log messages.
    private static final String LOG_TAG = "MainJavaDemo";
    private TextView statusView;

    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // User identifier for demo purposes. Replace with actual user ID in production.
        String myUserIdentifier = "tr-sdk-test-user-46183135";
        // API Token retrieved from resources. Replace with actual token.
        String myApiToken = getString(R.string.api_token);

        // Logging API Token and User Identifier for debug purposes.
        Log.d(LOG_TAG, "API Token: " + myApiToken);
        Log.d(LOG_TAG, "User identifier: " + myUserIdentifier);

        HashMap<String, Object> userAttributes = new HashMap<>();
        // Example user attributes. Replace or extend with relevant user data.
        userAttributes.put("age", 25);
        userAttributes.put("VIP", true);
        userAttributes.put("name", "John Doe");
        userAttributes.put("first_seen", Instant.now().toString());

        // Setting the main content view layout.
        setContentView(R.layout.activity_main);
        edgeToEdge(findViewById(R.id.root));
        statusView = findViewById(R.id.statusView);
        ListView listView = findViewById(R.id.listView);
        // Placeholder data until SDK is ready.
        String[] placements = {"Waiting for SDK to be ready..."};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, placements);
        listView.setAdapter(adapter);

        // Initialize the SDK with necessary parameters including callbacks for rewards and errors.
        TapResearch.INSTANCE.initialize(
                myApiToken, // Replace with your API Token
                myUserIdentifier, // Replace with your User Identifier
                MainActivity.this, // Current activity context
                this::showReward, // Callback to handle reward display
                this::showError, // Callback to handle errors
                // Callback indicating SDK is ready. Used to send user attributes and log readiness.
                () -> {
                    Log.d(LOG_TAG, "SDK Ready");
                    // Sending custom user attributes to the SDK.
                    TapResearch.INSTANCE.sendUserAttributes(userAttributes,
                            false,
                            trError -> statusView.setText("Error sending user attributes: " + trError.toString()));
                    // Setting up the main content view after initialization.
                    runOnUiThread(this::doSetContent);
                },
                // Callback for handling quick questions data.
                (qqData) -> {
                    statusView.setText("QQ Data: " + qqData);
                },
                new TapInitOptions(
                        userAttributes,
                        true // Optional parameter to clear previous user attributes
                ) // Optional initialization options
        );
    }

    // Method to update the content view with actual data after SDK initialization.
    @SuppressLint("SetTextI18n")
    private void doSetContent() {
        statusView.setText("SDK is ready");

        // Retrieve placement tags from resources.
        String[] placements = getResources().getStringArray(R.array.placement_tags);

        ListView listView = findViewById(R.id.listView);

        // Setting up the adapter with placement tags.
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, placements);
        listView.setAdapter(adapter);

        // Handling click events on the list items.
        listView.setOnItemClickListener((parent, view, position, id) -> {
            String selectedItem = placements[position];
            // Checking if content is available for the selected placement before showing.
            if (TapResearch.INSTANCE.canShowContentForPlacement(selectedItem, trError -> Log.d(LOG_TAG, "Whoops " + trError.toString()))) {
                // Custom parameters for the content display. Adjust as needed.
                HashMap<String, Object> customParameters = new HashMap<>();
                customParameters.put("age", 25);
                customParameters.put("VIP", "true");
                customParameters.put("name", "John Doe");
                customParameters.put("first_seen", Instant.now().toString());
                // Showing content for the selected placement with custom parameters.
                TapResearch.INSTANCE.showContentForPlacement(
                        selectedItem,
                        new TRContentCallback() {
                            @Override
                            public void onTapResearchContentShown(String placementTag) {
                                statusView.setText("Content shown");
                            }

                            @Override
                            public void onTapResearchContentDismissed(String placementTag) {
                                statusView.setText("Content dismissed");
                            }
                        },
                        customParameters,
                        this::showError,
                        null
                );
            }
            // Feedback toast for item click.
            statusView.setText("Clicked: " + selectedItem);
        });
    }

    // Method to display an error toast with the provided error description.
    private void showError(TRError error) {
        Log.d(LOG_TAG, "SDK error: " + error.getDescription());
        statusView.setText(error.getDescription());
    }

    // Method to display a reward toast summarizing the rewards earned.
    private void showReward(List<TRReward> rewards) {
        int rewardCount = 0;
        String currencyName = "";
        String eventType = "";
        // Sum up the rewards.
        for (TRReward reward : rewards) {
            Log.d(LOG_TAG, "reward: " + reward);
            if (reward.getRewardAmount() != null) {
                rewardCount += reward.getRewardAmount();
            }
            currencyName += reward.getCurrencyName()+" ";
            eventType += reward.getPayoutEventType()+" ";
        }

        // Displaying the total rewards earned in a toast message.

        statusView.setText("Congrats! You've earned [" + rewardCount + "] [" + currencyName + "]. Event type is " + eventType);
    }

    private void edgeToEdge(View view) {
        ViewCompat.setOnApplyWindowInsetsListener(view, (v, insets) -> {
            Insets bars = insets.getInsets(
                    WindowInsetsCompat.Type.systemBars()
                            | WindowInsetsCompat.Type.displayCutout()
            );
            v.setPadding(bars.left, bars.top, bars.right, bars.bottom);
            return WindowInsetsCompat.CONSUMED;
        });
    }

}
