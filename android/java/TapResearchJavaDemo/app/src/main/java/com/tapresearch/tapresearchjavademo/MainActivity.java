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
import com.tapresearch.tapsdk.models.PlacementCustomParameters;
import com.tapresearch.tapsdk.models.TRError;
import com.tapresearch.tapsdk.models.TRPlacement;
import com.tapresearch.tapsdk.models.TRReward;

import java.util.HashMap;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private static final String NORMAL_OFFER = "default-placement-a";
    private static final String BANNER_OFFER = "banner-placement-a";
    private static final String INTERSTITIAL_OFFER = "interstitial-placement-a";
    private static final String FLOATING_INTERSTITIAL_OFFER = "floating-interstitial-placement-a";
    private static final String CP_INTERSTITIAL_OFFER = "capped-and-paced-interstitial-a";
    
    String[] offers = {NORMAL_OFFER, BANNER_OFFER, INTERSTITIAL_OFFER, FLOATING_INTERSTITIAL_OFFER, CP_INTERSTITIAL_OFFER};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String myUserIdentifier = "public-demo-test-user";
        String myApiToken = "856f987d813389d1243bea2e4731a0fb";
        Log.d("MainActivity", "API Token: " + myApiToken);
        Log.d("MainActivity", "User identifier: " + myUserIdentifier);

        setContentView(R.layout.activity_main);
        ListView listView = findViewById(R.id.listView);

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, offers);
        listView.setAdapter(adapter);
        TapResearch.INSTANCE.initialize(myApiToken, myUserIdentifier, this, new TRRewardCallback() {
            @Override
            public void onReward(List<TRReward> rewards) {
                showRewardToast(rewards);
            }
        }, new TRErrorCallback() {
            @Override
            public void onError(TRError trError) {
                showErrorToast(trError);
            }
        });

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                String selectedItem = offers[position];
                if (TapResearch.INSTANCE.canShowContentForPlacement(selectedItem, new TRErrorCallback() {
                    @Override
                    public void onError(TRError trError) {
                        Log.d("TRLOG", "Whoops " + trError.toString());
                    }
                })) {

                    PlacementCustomParameters placementCustomParameters = new PlacementCustomParameters().fromMap(new HashMap<String, String>() {
                        {
                            put("paramKey", "param value");
                        }
                    });

                    TapResearch.INSTANCE.showContentForPlacement(
                            selectedItem,
                            getApplication(),
                            placementCustomParameters,
                            new TRContentCallback() {
                                @Override
                                public void onContentShown(TRPlacement trPlacement) {
                                    Log.d("TRLOG", "Content shown for placement " + trPlacement.toString());
                                }

                                @Override
                                public void onContentDismissed(TRPlacement trPlacement) {
                                    Log.d("TRLOG", "Content dismissed for placement " + trPlacement.toString());
                                }
                            },
                            new TRErrorCallback() {
                                @Override
                                public void onError(TRError trError) {
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
        Toast.makeText(MainActivity.this, error.description, Toast.LENGTH_LONG).show();
    }

    private void showRewardToast(List<TRReward> rewards) {
        int rewardCount = 0;
        for (TRReward reward : rewards) {
            Log.d("MainActivity", "reward: " + reward);
            if (reward.rewardAmount != null) {
                rewardCount += reward.rewardAmount;
            }
        }

        String currencyName = rewards.get(0).currencyName;
        String eventType = rewards.get(0).payoutEventType;
        Toast.makeText(MainActivity.this, "Congrats! You've earned " + rewardCount + " " + currencyName + ". Event type is " + eventType, Toast.LENGTH_LONG).show();
    }

}