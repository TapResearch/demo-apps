package com.tapresearch.tapresearchjavademo;

import android.annotation.SuppressLint;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.tapresearch.tapsdk.TapInitOptions;
import com.tapresearch.tapsdk.TapResearch;
import com.tapresearch.tapsdk.callback.TRContentCallback;
import com.tapresearch.tapsdk.models.TRError;
import com.tapresearch.tapsdk.models.TRPlacementDetails;
import com.tapresearch.tapsdk.models.TRReward;
import com.tapresearch.tapsdk.utils.TapErrorCodes;
import com.tapresearch.tapsdk.TapInitOptions;
import com.tapresearch.tapsdk.internal.SdkInitializer;
import com.tapresearch.tapsdk.internal.callback.TROfferNavigationPayload$Companion;
import com.tapresearch.tapsdk.internal.service.InternalService;


import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Toast;

import kotlinx.serialization.InternalSerializationApi;

@InternalSerializationApi
public class MainActivity extends AppCompatActivity {
    // Tag used for logging. Helps in identifying the source of log messages.
    private static final String LOG_TAG = "MainJavaDemo";
    private TextView statusView;
    private Button grantBoostButton;
    private EditText grantBoostEditText;

    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // User identifier for demo purposes. Replace with actual user ID in production.
        String myUserIdentifier = "tr-sdk-test-user-1112345678";  // after a few runs change the ending number to see behavior
        // API Token retrieved from resources. Replace with actual token.
        String myApiToken = "fb28e5e0572876db0790ecaf6c588598";  // this is the demo api token

        // Logging API Token and User Identifier for debug purposes.
        Log.d(LOG_TAG, "API Token: " + myApiToken);
        Log.d(LOG_TAG, "User identifier: " + myUserIdentifier);

        HashMap<String, Object> userAttributes = new HashMap<>();
        // Example user attributes. Replace or extend with relevant user data.
        userAttributes.put("age", 25);
        userAttributes.put("VIP", true);
        userAttributes.put("name", "John Doe");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            userAttributes.put("first_seen", Instant.now().toString());
        }

        // Setting the main content view layout.
        setContentView(R.layout.activity_main);
        statusView = findViewById(R.id.statusView);
        grantBoostButton = findViewById(R.id.grantBoostButton);
        grantBoostEditText = findViewById(R.id.grantBoostEditText);

        ListView listView = findViewById(R.id.listView);
        // Placeholder data until SDK is ready.
        String[] placements = {"Waiting for SDK to be ready..."};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, placements);
        listView.setAdapter(adapter);

        // Initialize the SDK with necessary parameters including callbacks for rewards and errors.
        TapResearch.INSTANCE.initialize(
                myApiToken, // Replace with your API Token
                myUserIdentifier, // Replace with your User Identifier
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
                    doSetContent();
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
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    customParameters.put("first_seen", Instant.now().toString());
                }
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
        findViewById(R.id.grantBoostLayout).setVisibility(View.VISIBLE);
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

    public void onGrantBoostButtonClicked(View view) {
        // 'boost-3x-1d' is an example boost tag
        TapResearch.INSTANCE.grantBoost(grantBoostEditText.getText().toString(), grantBoostResponse -> {
            if (grantBoostResponse.getSuccess() == true) {

                // example placement tag 'earn-center' should now be boosted
                TRPlacementDetails placementDetails = TapResearch.INSTANCE.getPlacementDetails("earn-center", null);
                if (placementDetails != null) {
                    // 'earn-center' placement details should now be boosted
                    Log.d(LOG_TAG, "placement details: " + placementDetails);
                    showAlertDialog(MainActivity.this, "Grant Boost Success", placementDetails.toString());
                }
            } else {
                Toast.makeText(MainActivity.this, grantBoostResponse.getError().getDescription(), Toast.LENGTH_SHORT).show();
                Log.d(LOG_TAG, "grantBoost error: " + grantBoostResponse.getError().getDescription());
            }
        });
    }

    static void showAlertDialog(Context context, String title, String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(title);
        builder.setMessage(message);
        AlertDialog dialog = builder.create();
        dialog.show();
    }

}
