//
// © 2024-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.android.admob;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.appopen.AppOpenAd;

import java.util.Date;

public class AppOpen {
    private static final String LOG_TAG = "godot::AppOpen";

    private final String adId;
    private final String adUnitId;
    private final Activity activity;
    private final AppOpenListener listener;
    private final AdRequest adRequest;

    private AppOpenAd appOpenAd;
    private boolean isLoaded;
    private long loadTime = 0;

    public AppOpen(String adId, String adUnitId, AdRequest adRequest, Activity activity, AppOpenListener listener) {
        this.adId = adId;
        this.adUnitId = adUnitId;
        this.activity = activity;
        this.listener = listener;
        this.adRequest = adRequest;
        this.isLoaded = false;
    }

    public void load() {
        Log.d(LOG_TAG, String.format("load(): %s", adId));

        if (isAdAvailable()) {
            Log.d(LOG_TAG, String.format("load(): ad already loaded: %s", adId));
            listener.onAppOpenLoaded(adId);
            return;
        }

        AppOpenAd.load(
                activity,
                adUnitId,
                adRequest,
                new AppOpenAd.AppOpenAdLoadCallback() {
                    @Override
                    public void onAdLoaded(@NonNull AppOpenAd ad) {
                        Log.d(LOG_TAG, String.format("onAdLoaded(): %s", adId));
                        appOpenAd = ad;
                        isLoaded = true;
                        loadTime = (new Date()).getTime();
                        
                        appOpenAd.setFullScreenContentCallback(new FullScreenContentCallback() {
                            @Override
                            public void onAdClicked() {
                                Log.d(LOG_TAG, String.format("onAdClicked(): %s", adId));
                                listener.onAppOpenClicked(adId);
                            }

                            @Override
                            public void onAdDismissedFullScreenContent() {
                                Log.d(LOG_TAG, String.format("onAdDismissedFullScreenContent(): %s", adId));
                                appOpenAd = null;
                                isLoaded = false;
                                listener.onAppOpenClosed(adId);
                            }

                            @Override
                            public void onAdFailedToShowFullScreenContent(AdError adError) {
                                Log.d(LOG_TAG, String.format("onAdFailedToShowFullScreenContent(): %s", adId));
                                appOpenAd = null;
                                isLoaded = false;
                                listener.onAppOpenFailedToShow(adId, adError);
                            }

                            @Override
                            public void onAdImpression() {
                                Log.d(LOG_TAG, String.format("onAdImpression(): %s", adId));
                                listener.onAppOpenImpression(adId);
                            }

                            @Override
                            public void onAdShowedFullScreenContent() {
                                Log.d(LOG_TAG, String.format("onAdShowedFullScreenContent(): %s", adId));
                                listener.onAppOpenOpened(adId);
                            }
                        });

                        listener.onAppOpenLoaded(adId);
                    }

                    @Override
                    public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                        Log.e(LOG_TAG, String.format("onAdFailedToLoad(): %s, error: %s", adId, loadAdError.getMessage()));
                        isLoaded = false;
                        appOpenAd = null;
                        listener.onAppOpenFailedToLoad(adId, loadAdError);
                    }
                });
    }

    public void show() {
        if (isAdAvailable()) {
            Log.d(LOG_TAG, String.format("show(): %s", adId));
            appOpenAd.show(activity);
        } else {
            Log.w(LOG_TAG, String.format("show(): ad not ready: %s", adId));
            load();
        }
    }

    private boolean wasLoadTimeLessThanNHoursAgo(long numHours) {
        long dateDifference = (new Date()).getTime() - loadTime;
        long numMilliSecondsPerHour = 3600000;
        return (dateDifference < (numMilliSecondsPerHour * numHours));
    }

    private boolean isAdAvailable() {
        return appOpenAd != null && isLoaded && wasLoadTimeLessThanNHoursAgo(4);
    }

    public interface AppOpenListener {
        void onAppOpenLoaded(String adId);
        void onAppOpenFailedToLoad(String adId, LoadAdError loadAdError);
        void onAppOpenOpened(String adId);
        void onAppOpenFailedToShow(String adId, AdError adError);
        void onAppOpenClosed(String adId);
        void onAppOpenClicked(String adId);
        void onAppOpenImpression(String adId);
    }
}
