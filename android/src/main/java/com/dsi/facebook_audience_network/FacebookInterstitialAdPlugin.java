package com.dsi.facebook_audience_network;


import android.content.Context;
import android.os.Handler;
import android.util.Log;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.CacheFlag;
import com.facebook.ads.InterstitialAd;
import com.facebook.ads.InterstitialAdListener;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class FacebookInterstitialAdPlugin implements MethodChannel.MethodCallHandler, InterstitialAdListener {

    private InterstitialAd interstitialAd = null;

    private Context context;
    private MethodChannel channel;

    private Handler _delayHandler;

    FacebookInterstitialAdPlugin(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;

        _delayHandler = new Handler();
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        switch (methodCall.method) {
            case FacebookConstants.SHOW_INTERSTITIAL_METHOD:
                result.success(showAd((HashMap) methodCall.arguments));
                break;
            case FacebookConstants.LOAD_INTERSTITIAL_METHOD:
                result.success(loadAd((HashMap) methodCall.arguments));
                break;
            case FacebookConstants.DESTROY_INTERSTITIAL_METHOD:
                result.success(destroyAd());
                break;
            default:
                result.notImplemented();
        }
    }

    private boolean loadAd(HashMap args) {
        final String placementId = (String) args.get("id");

        if (interstitialAd == null) {
            interstitialAd = new InterstitialAd(context, placementId);
        }
        try {
            if (!interstitialAd.isAdLoaded()) {
                InterstitialAd.InterstitialLoadAdConfig loadAdConfig = interstitialAd.buildLoadAdConfig().withAdListener(this).withCacheFlags(CacheFlag.ALL).build();

                interstitialAd.loadAd(loadAdConfig);
            }
        } catch (Exception e) {
            Log.e("InterstitialLoadAdError", e.getCause().getMessage());
            return false;
        }

        return true;
    }

    private boolean showAd(HashMap args) {
        final int delay = (int) args.get("delay");

        if (interstitialAd == null || !interstitialAd.isAdLoaded())
            return false;

        if (interstitialAd.isAdInvalidated())
            return false;

        if (delay <= 0) {
            InterstitialAd.InterstitialShowAdConfig showAdConfig = interstitialAd.buildShowAdConfig().build();
            interstitialAd.show(showAdConfig);
        } else {
            _delayHandler.postDelayed(new Runnable() {
                @Override
                public void run() {

                    if (interstitialAd == null || !interstitialAd.isAdLoaded())
                        return;

                    if (interstitialAd.isAdInvalidated())
                        return;
                    InterstitialAd.InterstitialShowAdConfig showAdConfig = interstitialAd.buildShowAdConfig().build();

                    interstitialAd.show(showAdConfig);
                }
            }, delay);
        }
        return true;
    }

    private boolean destroyAd() {
        if (interstitialAd == null)
            return false;
        else {
            interstitialAd.destroy();
            interstitialAd = null;
        }
        return true;
    }

    @Override
    public void onInterstitialDisplayed(Ad ad) {
        HashMap<String, Object> args = new HashMap<>();
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.DISPLAYED_METHOD, args);
    }

    @Override
    public void onInterstitialDismissed(Ad ad) {
        HashMap<String, Object> args = new HashMap<>();
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.DISMISSED_METHOD, args);
    }

    @Override
    public void onError(Ad ad, AdError adError) {
        HashMap<String, Object> args = new HashMap<>();
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());
        args.put("error_code", adError.getErrorCode());
        args.put("error_message", adError.getErrorMessage());

        channel.invokeMethod(FacebookConstants.ERROR_METHOD, args);
    }

    @Override
    public void onAdLoaded(Ad ad) {
        HashMap<String, Object> args = new HashMap<>();
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.LOADED_METHOD, args);
    }

    @Override
    public void onAdClicked(Ad ad) {
        HashMap<String, Object> args = new HashMap<>();
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.CLICKED_METHOD, args);
    }

    @Override
    public void onLoggingImpression(Ad ad) {
        HashMap<String, Object> args = new HashMap<>();
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.LOGGING_IMPRESSION_METHOD, args);
    }
}
