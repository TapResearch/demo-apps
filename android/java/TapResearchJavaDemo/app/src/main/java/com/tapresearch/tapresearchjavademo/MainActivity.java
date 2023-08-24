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

import java.util.List;

public class MainActivity extends AppCompatActivity {

    private static final String NORMAL_OFFER = "default-placement-a";
    private static final String BANNER_OFFER = "banner-placement-a";
    private static final String INTERSTITIAL_OFFER = "interstitial-placement-a";
    private static final String PARTIAL_INTERSTITIAL_OFFER = "partial-interstitial-placement-a";
    private static final String CP_INTERSTITIAL_OFFER = "capped-and-paced-interstitial-a";
    private static final String LOG_TAG = "MainActivity";

    String[] offers = {NORMAL_OFFER, BANNER_OFFER, INTERSTITIAL_OFFER, PARTIAL_INTERSTITIAL_OFFER, CP_INTERSTITIAL_OFFER};
    private boolean tapSdkReady = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String myUserIdentifier = "public-demo-test-user";
        String myApiToken = "856f987d813389d1243bea2e4731a0fb";
        Log.d(LOG_TAG, "API Token: " + myApiToken);
        Log.d(LOG_TAG, "User identifier: " + myUserIdentifier);

        setContentView(R.layout.activity_main);
        ListView listView = findViewById(R.id.listView);

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, offers);
        listView.setAdapter(adapter);
        TapResearch.INSTANCE.initialize(getString(R.string.api_token), myUserIdentifier,
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
                        tapSdkReady = true;
                    }
                },
                new TRContentCallback() {
                    @Override
                    public void onContentShown(String placementTag) {
                        Log.d(LOG_TAG, "Content shown for placement " + placementTag);
                    }

                    @Override
                    public void onContentDismissed(String placementTag) {
                        Log.d(LOG_TAG, "Content dismissed for placement " + placementTag);
                    }
                });
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                String selectedItem = offers[position];
                if (!tapSdkReady){
                    Toast.makeText(MainActivity.this, "TapSDK not yet ready", Toast.LENGTH_SHORT).show();
                    return;
                }
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