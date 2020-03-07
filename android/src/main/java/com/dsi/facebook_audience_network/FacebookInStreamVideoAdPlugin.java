package com.dsi.facebook_audience_network;

import android.content.Context;
import android.view.View;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.AdSize;
import com.facebook.ads.InstreamVideoAdListener;
import com.facebook.ads.InstreamVideoAdView;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

class FacebookInStreamVideoAdPlugin extends PlatformViewFactory {
    private final BinaryMessenger messenger;


    FacebookInStreamVideoAdPlugin(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new FacebookInStreamVideoAdView(context, id,
                (HashMap) args, this.messenger);
    }
}

class FacebookInStreamVideoAdView implements PlatformView, InstreamVideoAdListener {
    private final InstreamVideoAdView adView;
    private final MethodChannel channel;

    FacebookInStreamVideoAdView(Context context, int id, HashMap args, BinaryMessenger messenger) {

        this.channel = new MethodChannel(messenger,
                FacebookConstants.IN_STREAM_VIDEO_CHANNEL + "_" + id);

        adView = new InstreamVideoAdView(context, (String) args.get("id"), getSize(args));
        InstreamVideoAdView.InstreamVideoLoadAdConfig loadAdConfig = adView.buildLoadAdConfig().withAdListener(this).build();

        adView.loadAd(loadAdConfig);
    }

    @Override
    public View getView() {
        return adView;
    }

    @Override
    public void dispose() {
//        if (adView != null)
//        {
//            adView.setAdListener(null);
//            adView.destroy();
//        }
    }

    private AdSize getSize(HashMap args) {
        int width = (int) args.get("width");
        int height = (int) args.get("height");

        return new AdSize(width, height);
    }

    @Override
    public void onAdVideoComplete(Ad ad) {
        HashMap<String, Object> args = new HashMap<>();
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.IN_STREAM_VIDEO_COMPLETE_METHOD, args);
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

        if (adView == null || !adView.isAdLoaded())
            return;

        adView.show();
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
