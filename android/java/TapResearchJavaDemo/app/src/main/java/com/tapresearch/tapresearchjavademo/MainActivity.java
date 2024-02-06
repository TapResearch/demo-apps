package com.tapresearch.tapresearchjavademo;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tapresearch.tapsdk.TapInitOptions;
import com.tapresearch.tapsdk.TapResearch;
import com.tapresearch.tapsdk.callback.TRContentCallback;
import com.tapresearch.tapsdk.callback.TRErrorCallback;
import com.tapresearch.tapsdk.callback.TRQQDataCallback;
import com.tapresearch.tapsdk.callback.TRRewardCallback;
import com.tapresearch.tapsdk.callback.TRSdkReadyCallback;
import com.tapresearch.tapsdk.models.TRError;
import com.tapresearch.tapsdk.models.TRReward;


import java.time.Instant;
import java.util.HashMap;
import java.util.List;


public class MainActivity extends AppCompatActivity {
    // Tag used for logging. Helps in identifying the source of log messages.
    private static final String LOG_TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // User identifier for demo purposes. Replace with actual user ID in production.
        String myUserIdentifier = "public-demo-test-user";
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

        // Initialize the SDK with necessary parameters including callbacks for rewards and errors.
        TapResearch.INSTANCE.initialize(
                myApiToken, // Replace with your API Token
                myUserIdentifier, // Replace with your User Identifier
                MainActivity.this, // Current activity context
                this::showRewardToast, // Callback to handle reward display
                this::showErrorToast, // Callback to handle errors
                // Callback indicating SDK is ready. Used to send user attributes and log readiness.
                () -> {
                    Log.d(LOG_TAG, "SDK is ready");

                    // Sending custom user attributes to the SDK.
                    TapResearch.INSTANCE.sendUserAttributes(userAttributes,
                            trError -> Log.d(LOG_TAG, "Error sending user attributes: " + trError.toString()));
                    // Setting up the main content view after initialization.
                    doSetContent();
                },
                // Callback for handling quick questions data.
                (qqData) -> {
                    Log.d(LOG_TAG, "QQ Data: " + qqData);
                },
                new TapInitOptions(
                        userAttributes,
                        true // Optional parameter to clear previous user attributes
                ) // Optional initialization options
        );

        // Setting the main content view layout.
        setContentView(R.layout.activity_main);
        ListView listView = findViewById(R.id.listView);
        // Placeholder data until SDK is ready.
        String[] placements = {"Waiting for SDK to be ready..."};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, placements);
        listView.setAdapter(adapter);
    }

    // Method to update the content view with actual data after SDK initialization.
    private void doSetContent() {
        // Retrieve placement tags from resources.
        String[] placements = getResources().getStringArray(R.array.placement_tags);

        // Re-setting the content view layout. May be redundant if not changing layouts.
        setContentView(R.layout.activity_main);
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
                        getApplication(),
                        new TRContentCallback() {
                            @Override
                            public void onTapResearchContentShown(String placementTag) {
                                Log.d(LOG_TAG, "Content shown");
                            }

                            @Override
                            public void onTapResearchContentDismissed(String placementTag) {
                                Log.d(LOG_TAG, "Content dismissed");
                            }
                        },
                        customParameters,
                        this::showErrorToast
                );
            }
            // Feedback toast for item click.
            Toast.makeText(MainActivity.this, "Clicked: " + selectedItem, Toast.LENGTH_SHORT).show();
        });
    }

    // Method to display an error toast with the provided error description.
    private void showErrorToast(TRError error) {
        Toast.makeText(MainActivity.this, error.getDescription(), Toast.LENGTH_LONG).show();
    }

    // Method to display a reward toast summarizing the rewards earned.
    private void showRewardToast(List<TRReward> rewards) {
        int rewardCount = 0;
        // Sum up the rewards.
        for (TRReward reward : rewards) {
            Log.d(LOG_TAG, "reward: " + reward);
            if (reward.getRewardAmount() != null) {
                rewardCount += reward.getRewardAmount();
            }
        }

        // Displaying the total rewards earned in a toast message.
        String currencyName = rewards.get(0).getCurrencyName();
        String eventType = rewards.get(0).getPayoutEventType();
        Toast.makeText(MainActivity.this, "Congrats! You've earned " + rewardCount + " " + currencyName + ". Event type is " + eventType, Toast.LENGTH_LONG).show();
    }

}
