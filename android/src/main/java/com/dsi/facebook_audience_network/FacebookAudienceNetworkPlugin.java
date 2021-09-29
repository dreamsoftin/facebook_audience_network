package com.dsi.facebook_audience_network;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.facebook.ads.*;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.platform.PlatformViewRegistry;

/**
 * FacebookAudienceNetworkPlugin
 */
public class FacebookAudienceNetworkPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    private Activity mActivity = null;

    public FacebookAudienceNetworkPlugin() {}

    private FacebookAudienceNetworkPlugin(Activity activity) {
        this.mActivity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        registerWithInternal(new FacebookAudienceNetworkPlugin(registrar.activity()), registrar.messenger(),
                registrar.context(), registrar.platformViewRegistry() );
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        if (call.method.equals(FacebookConstants.INIT_METHOD))
            result.success(init((HashMap) call.arguments));
        else
            result.notImplemented();
    }

    private boolean init(HashMap initValues) {
        final String testingId = (String) initValues.get("testingId");

        if (mActivity != null)
            AudienceNetworkAds.initialize(mActivity.getApplicationContext());

        if (testingId != null) {
            AdSettings.addTestDevice(testingId);
        }
        return true;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        registerWithInternal(this, binding.getBinaryMessenger(),
                binding.getApplicationContext(), binding.getPlatformViewRegistry());
    }

    private static void registerWithInternal(MethodCallHandler plugin, BinaryMessenger binaryMessenger, Context context, PlatformViewRegistry platformViewRegistry)
    {
        // Main channel for initialization
        final MethodChannel channel = new MethodChannel(binaryMessenger,
                FacebookConstants.MAIN_CHANNEL);
        channel.setMethodCallHandler(plugin);

        // Interstitial Ad channel
        final MethodChannel interstitialAdChannel = new MethodChannel(binaryMessenger,
                FacebookConstants.INTERSTITIAL_AD_CHANNEL);
        interstitialAdChannel
                .setMethodCallHandler(new FacebookInterstitialAdPlugin(context,
                        interstitialAdChannel));

        // Rewarded video Ad channel
        final MethodChannel rewardedAdChannel = new MethodChannel(binaryMessenger,
                FacebookConstants.REWARDED_VIDEO_CHANNEL);
        rewardedAdChannel
                .setMethodCallHandler(new FacebookRewardedVideoAdPlugin(context,
                        rewardedAdChannel));

        // Banner Ad PlatformView channel
        platformViewRegistry.
                registerViewFactory(FacebookConstants.BANNER_AD_CHANNEL,
                        new FacebookBannerAdPlugin(binaryMessenger));

        // Native Ad PlatformView channel
        platformViewRegistry.
                registerViewFactory(FacebookConstants.NATIVE_AD_CHANNEL,
                        new FacebookNativeAdPlugin(binaryMessenger));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        mActivity = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

        mActivity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        mActivity = null;
    }
}

