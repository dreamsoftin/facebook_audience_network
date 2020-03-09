package com.dsi.facebook_audience_network;

import android.content.Context;
import android.os.Handler;
import android.util.Log;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.RewardedVideoAd;
import com.facebook.ads.RewardedVideoAdListener;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class FacebookRewardedVideoAdPlugin implements MethodChannel.MethodCallHandler,
        RewardedVideoAdListener {

    private RewardedVideoAd rewardedVideoAd = null;

    private Context context;
    private MethodChannel channel;

    private Handler _delayHandler;

    FacebookRewardedVideoAdPlugin(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;

        _delayHandler = new Handler();
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        switch (methodCall.method) {
            case FacebookConstants.SHOW_REWARDED_VIDEO_METHOD:
                result.success(showAd((HashMap) methodCall.arguments));
                break;
            case FacebookConstants.LOAD_REWARDED_VIDEO_METHOD:
                result.success(loadAd((HashMap) methodCall.arguments));
                break;
            case FacebookConstants.DESTROY_REWARDED_VIDEO_METHOD:
                result.success(destroyAd());
                break;
            default:
                result.notImplemented();
        }
    }

    private boolean loadAd(HashMap args) {
        final String placementId = (String) args.get("id");

        if (rewardedVideoAd == null) {
            rewardedVideoAd = new RewardedVideoAd(context, placementId);
        }
        try {
            if (!rewardedVideoAd.isAdLoaded()) {
                RewardedVideoAd.RewardedVideoLoadAdConfig loadAdConfig = rewardedVideoAd.buildLoadAdConfig().withAdListener(this).build();

                rewardedVideoAd.loadAd(loadAdConfig);
            }
        } catch (Exception e) {
            Log.e("RewardedVideoAdError", e.getMessage());
            return false;
        }

        return true;
    }

    private boolean showAd(HashMap args) {
        final int delay = (int) args.get("delay");

        if (rewardedVideoAd == null || !rewardedVideoAd.isAdLoaded())
            return false;

        if (rewardedVideoAd.isAdInvalidated())
            return false;

        if (delay <= 0) {
            RewardedVideoAd.RewardedVideoShowAdConfig showAdConfig = rewardedVideoAd.buildShowAdConfig().build();

            rewardedVideoAd.show(showAdConfig);
        } else {
            _delayHandler.postDelayed(new Runnable() {
                @Override
                public void run() {

                    if (rewardedVideoAd == null || !rewardedVideoAd.isAdLoaded())
                        return;

                    if (rewardedVideoAd.isAdInvalidated())
                        return;
                    RewardedVideoAd.RewardedVideoShowAdConfig showAdConfig = rewardedVideoAd.buildShowAdConfig().build();

                    rewardedVideoAd.show(showAdConfig);
                }
            }, delay);
        }
        return true;
    }

    private boolean destroyAd() {
        if (rewardedVideoAd == null)
            return false;
        else {
            rewardedVideoAd.destroy();
            rewardedVideoAd = null;
        }
        return true;
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

    @Override
    public void onRewardedVideoCompleted() {
        channel.invokeMethod(FacebookConstants.REWARDED_VIDEO_COMPLETE_METHOD, true);
    }

    @Override
    public void onRewardedVideoClosed() {
        channel.invokeMethod(FacebookConstants.REWARDED_VIDEO_CLOSED_METHOD, true);
    }
}
