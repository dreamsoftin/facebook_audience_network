package com.dsi.facebook_audience_network;

import android.app.Activity;
import android.media.FaceDetector;

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

    private Activity mActivity;

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

        // Banner Ad PlatformView channel
        registrar.platformViewRegistry().registerViewFactory(FacebookConstants.BANNER_AD_CHANNEL,
                new FacebookBannerAdPlugin(registrar.messenger()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        if (call.method.equals(FacebookConstants.INIT_METHOD))
            result.success(init((HashMap) call.arguments));
        else
            result.notImplemented();
    }

    private boolean init(HashMap initVals) {
        final String testingId = (String) initVals.get("testingId");

        AudienceNetworkAds.initialize(mActivity.getApplicationContext());

        if (testingId != null) {
            AdSettings.addTestDevice(testingId);
        }
        return true;
    }

}

