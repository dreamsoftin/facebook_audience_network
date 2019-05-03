package com.dsi.facebook_audience_network;

import android.app.Activity;
import android.media.FaceDetector;
import android.util.DisplayMetrics;

import com.facebook.ads.*;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * FacebookAudienceNetworkPlugin
 */
public class FacebookAudienceNetworkPlugin implements MethodCallHandler {

    private final Activity mActivity;

    private FacebookAudienceNetworkPlugin(Activity activity) {
        this.mActivity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(PluginRegistry.Registrar registrar) {

        // Main channel for initialization
        final MethodChannel channel = new MethodChannel(registrar.messenger(),
                FacebookConstants.MAIN_CHANNEL);
        channel.setMethodCallHandler(new FacebookAudienceNetworkPlugin(registrar.activity()));

        // Interstitial Ad channel
        final MethodChannel interstitialAdChannel = new MethodChannel(registrar.messenger(),
                FacebookConstants.INTERSTITIAL_AD_CHANNEL);
        interstitialAdChannel
                .setMethodCallHandler(new FacebookInterstitialAdPlugin(registrar.context(),
                        interstitialAdChannel));

        // Rewarded video Ad channel
        final MethodChannel rewardedAdChannel = new MethodChannel(registrar.messenger(),
                FacebookConstants.REWARDED_VIDEO_CHANNEL);
        rewardedAdChannel
                .setMethodCallHandler(new FacebookRewardedVideoAdPlugin(registrar.context(),
                        rewardedAdChannel));

        // Banner Ad PlatformView channel
        registrar.
                platformViewRegistry().
                registerViewFactory(FacebookConstants.BANNER_AD_CHANNEL,
                        new FacebookBannerAdPlugin(registrar.messenger()));

        // InStream Video Ad PlatformView channel
        registrar.
                platformViewRegistry().
                registerViewFactory(FacebookConstants.IN_STREAM_VIDEO_CHANNEL,
                        new FacebookInStreamVideoAdPlugin(registrar.messenger()));

    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        if (call.method.equals(FacebookConstants.INIT_METHOD))
            result.success(init((HashMap) call.arguments));
        else
            result.notImplemented();
    }

    private boolean init(HashMap initValues) {
        final String testingId = (String) initValues.get("testingId");

        AudienceNetworkAds.initialize(mActivity.getApplicationContext());

        if (testingId != null) {
            AdSettings.addTestDevice(testingId);
        }
        return true;
    }

}

