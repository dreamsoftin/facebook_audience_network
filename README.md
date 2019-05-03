# facebook_audience_network

[Facebook Audience Network](https://developers.facebook.com/docs/audience-network) plugin for Flutter applications.

**Note: Currently only Android platform is supported.** 

![Pub](https://img.shields.io/pub/v/facebook_audience_network.svg) ![GitHub](https://img.shields.io/github/license/dreamsoftin/facebook_audience_network.svg)

## Getting Started

### 1. Initialization:

For testing purposes you need to obtain the hashed ID of your testing device. To obtain the hashed ID: 

1. Call `FacebookAudienceNetwork.init()` during app initialization.
2. Place the `FacebookBannerAd` widget in your app.
3. Run the app.

The hased id will be in printed to the logcat. Paste that onto the `testingId` parameter.

```dart
FacebookAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6",
      );
```
### 2. Show Banner Ad:

```dart
Container(
  alignment: Alignment(0.5, 1),
  child: FacebookBannerAd(
    placementId: "YOUR_PLACEMENT_ID",
    bannerSize: BannerSize.STANDARD,
    listener: (result, value) {
      switch (result) {
        case BannerAdResult.ERROR:
          print("Error: $value");
          break;
        case BannerAdResult.LOADED:
          print("Loaded: $value");
          break;
        case BannerAdResult.CLICKED:
          print("Clicked: $value");
          break;
        case BannerAdResult.LOGGING_IMPRESSION:
          print("Logging Impression: $value");
          break;
      }
    },
  ),
)
```

### 3. Show Interstitial Ad:

```dart
FacebookInterstitialAd.loadInterstitialAd(
  placementId: "YOUR_PLACEMENT_ID",
  listener: (result, value) {
    if (result == InterstitialAdResult.LOADED)
      FacebookInterstitialAd.showInterstitialAd(delay: 5000);
  },
);
```
### 4. Show Rewarded Video Ad:

```dart
FacebookRewardedVideoAd.loadRewardedVideoAd(
  placementId: "YOUR_PLACEMENT_ID",
  listener: (result, value) {
    if(result == RewardedVideoResult.LOADED)
      FacebookRewardedVideoAd.showRewardedVideoAd();
    if(result == RewardedVideoResult.VIDEO_COMPLETE)
      print("Video completed");
  },
);
```

### 5. Show In-Stream Video Ad:
Make sure to give proper width and height.

```dart
FacebookInStreamVideoAd(
  placementId: "YOUR_PLACEMENT_ID",
  height: 300,
  listener: (result, value) {
    if (result == InStreamVideoAdResult.VIDEO_COMPLETE) {
      setState(() {
        _videoComplete = true;
      });
    }
  },
)
```

**Check out the [example](https://github.com/dreamsoftin/facebook_audience_network/tree/master/example) for complete implementation.**

## Future Work
Implement for iOS platform.

