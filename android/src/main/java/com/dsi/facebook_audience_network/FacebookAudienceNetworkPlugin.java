package com.dsi.facebook_audience_network;

import android.app.Activity;

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

    static String placementId = "YOUR_PLACEMENT_ID";

    private Activity mActivity;

    private FacebookAudienceNetworkPlugin(Activity activity) {
        this.mActivity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(PluginRegistry.Registrar registrar) {


        registrar.platformViewRegistry().registerViewFactory("fb.audience.network.io/bannerAd",
                new FacebookBannerAdPlugin(registrar.messenger()));

        final MethodChannel channel = new MethodChannel(registrar.messenger(),
                "fb.audience.network.io");
        channel.setMethodCallHandler(new FacebookAudienceNetworkPlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        switch (call.method) {
            case "init":
                result.success(init((HashMap) call.arguments));
                break;
            default:
                result.notImplemented();
        }
    }
    
    private boolean init(HashMap initVals) {
        final String placementId = (String) initVals.get("placementId");
        final String testingId = (String) initVals.get("testingId");

        AudienceNetworkAds.initialize(mActivity.getApplicationContext());

        if(testingId != null) {
            AdSettings.addTestDevice(testingId);
        }
        if(placementId != null) {
            FacebookAudienceNetworkPlugin.placementId = placementId;
        }
        return true;
    }

}

