package com.tapresearch.tapresearchjavademo;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tapresearch.tapsdk.TapResearch;
import com.tapresearch.tapsdk.callback.TRContentCallback;
import com.tapresearch.tapsdk.callback.TRErrorCallback;
import com.tapresearch.tapsdk.callback.TRRewardCallback;
import com.tapresearch.tapsdk.callback.TRSdkReadyCallback;
import com.tapresearch.tapsdk.models.TRError;
import com.tapresearch.tapsdk.models.TRReward;


import java.time.Instant;
import java.util.HashMap;
import java.util.List;

public class MainActivity extends AppCompatActivity {
    private static final String LOG_TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String myUserIdentifier = "public-demo-test-user";
        String myApiToken = getString(R.string.api_token);
        Log.d(LOG_TAG, "API Token: " + myApiToken);
        Log.d(LOG_TAG, "User identifier: " + myUserIdentifier);

        TapResearch.INSTANCE.initialize(myApiToken, myUserIdentifier,
                MainActivity.this,
                new TRRewardCallback() {
                    @Override
                    public void onTapResearchDidReceiveRewards(List<TRReward> rewards) {
                        showRewardToast(rewards);
                    }
                },
                new TRErrorCallback() {
                    @Override
                    public void onTapResearchDidError(TRError trError) {
                        showErrorToast(trError);
                    }
                },
                new TRSdkReadyCallback() {
                    @Override
                    public void onTapResearchSdkReady() {
                        Log.d(LOG_TAG, "SDK is ready");
                        HashMap<String, Object> userAttributes = new HashMap<>();
                        userAttributes.put("age", 25);
                        userAttributes.put("VIP", true);
                        userAttributes.put("name", "John Doe");
                        userAttributes.put("first_seen", Instant.now().toString());

                        TapResearch.INSTANCE.sendUserAttributes(userAttributes, new TRErrorCallback() {
                            @Override
                            public void onTapResearchDidError(TRError trError) {
                                Log.d(LOG_TAG, "Error sending user attributes: " + trError.toString());
                            }
                        });
                        doSetContent();
                    }
                },
                new TRContentCallback() {
                    @Override
                    public void onTapResearchContentShown(String placementTag) {
                        Log.d(LOG_TAG, "Content shown for placement " + placementTag);
                    }

                    @Override
                    public void onTapResearchContentDismissed(String placementTag) {
                        Log.d(LOG_TAG, "Content dismissed for placement " + placementTag);
                    }
                });

        setContentView(R.layout.activity_main);
        ListView listView = findViewById(R.id.listView);
        String[] placements = {"Waiting for SDK to be ready..."};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, placements);
        listView.setAdapter(adapter);


    }

    private void doSetContent() {
        String[] placements = getResources().getStringArray(R.array.placement_tags);

        setContentView(R.layout.activity_main);
        ListView listView = findViewById(R.id.listView);

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, placements);
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                String selectedItem = placements[position];
                if (TapResearch.INSTANCE.canShowContentForPlacement(selectedItem, new TRErrorCallback() {
                    @Override
                    public void onTapResearchDidError(TRError trError) {
                        Log.d(LOG_TAG, "Whoops " + trError.toString());
                    }
                })) {
                    TapResearch.INSTANCE.showContentForPlacement(
                            selectedItem,
                            getApplication(),
                            new TRErrorCallback() {
                                @Override
                                public void onTapResearchDidError(TRError trError) {
                                    showErrorToast(trError);
                                }
                            }
                    );
                }
                Toast.makeText(MainActivity.this, "Clicked: " + selectedItem, Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void showErrorToast(TRError error) {
        Toast.makeText(MainActivity.this, error.getDescription(), Toast.LENGTH_LONG).show();
    }

    private void showRewardToast(List<TRReward> rewards) {
        int rewardCount = 0;
        for (TRReward reward : rewards) {
            Log.d(LOG_TAG, "reward: " + reward);
            if (reward.getRewardAmount() != null) {
                rewardCount += reward.getRewardAmount();
            }
        }

        String currencyName = rewards.get(0).getCurrencyName();
        String eventType = rewards.get(0).getPayoutEventType();
        Toast.makeText(MainActivity.this, "Congrats! You've earned " + rewardCount + " " + currencyName + ". Event type is " + eventType, Toast.LENGTH_LONG).show();
    }

}