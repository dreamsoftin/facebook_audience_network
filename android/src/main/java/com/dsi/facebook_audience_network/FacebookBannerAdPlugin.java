package com.dsi.facebook_audience_network;

import android.content.Context;
import android.view.View;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.AdListener;
import com.facebook.ads.AdSize;
import com.facebook.ads.AdView;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FacebookBannerAdPlugin extends PlatformViewFactory {

    private final BinaryMessenger messenger;


    FacebookBannerAdPlugin(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new FacebookBannerAdView(context, id, (HashMap) args, this.messenger);
    }
}

class FacebookBannerAdView implements PlatformView, AdListener {
    private AdView adView;
    private MethodChannel channel;

    FacebookBannerAdView(Context context, int id, HashMap args, BinaryMessenger messenger) {

        channel = new MethodChannel(messenger, FacebookConstants.BANNER_AD_CHANNEL + "_" + id);

        adView = new AdView(context,
                (String) args.get("id"),
                getBannerSize(args));

        adView.setAdListener(this);
        adView.loadAd();
    }

    private AdSize getBannerSize(HashMap args) {
//        final int width = (int) args.get("width");
        final int height = (int) args.get("height");

        if (height >= 250)
            return AdSize.RECTANGLE_HEIGHT_250;
        if (height >= 90)
            return AdSize.BANNER_HEIGHT_90;
        else
            return AdSize.BANNER_HEIGHT_50;
    }

    @Override
    public View getView() {
        return adView;
    }

    @Override
    public void dispose() {
        if (adView != null)
            adView.destroy();
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


