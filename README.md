# facebook_audience_network
![Pub](https://img.shields.io/pub/v/facebook_audience_network.svg) ![GitHub](https://img.shields.io/github/license/dreamsoftin/facebook_audience_network.svg)

[Facebook Audience Network](https://developers.facebook.com/docs/audience-network) plugin for Flutter applications.

**Note: Currently only Android platform is supported.** 


| Banner Ad | Native Banner Ad | Native Ad |
| - | - | - |
| ![Banner Ad](https://raw.githubusercontent.com/dreamsoftin/facebook_audience_network/master/example/gifs/banner.gif "Banner Ad") | ![Native Banner Ad](https://raw.githubusercontent.com/dreamsoftin/facebook_audience_network/master/example/gifs/native_banner.gif "Native Banner Ad") | ![Native Ad](https://raw.githubusercontent.com/dreamsoftin/facebook_audience_network/master/example/gifs/native.gif "Native Ad") |

| Interstitial Ad | Rewarded Video Ad | In-Stream Video Ad |
| - | - | - |
| ![Interstitial Ad](https://raw.githubusercontent.com/dreamsoftin/facebook_audience_network/master/example/gifs/interstitial.gif "Interstitial Ad") | ![Rewarded Ad](https://raw.githubusercontent.com/dreamsoftin/facebook_audience_network/master/example/gifs/rewarded.gif "Rewarded Video Ad") | ![InStream Ad](https://raw.githubusercontent.com/dreamsoftin/facebook_audience_network/master/example/gifs/instream.gif "InStream Video Ad") |


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
Make sure the width and height is 300 at minimum.

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

### 6. Show Native Ad:

```dart
FacebookNativeAd(
  placementId: "YOUR_PLACEMENT_ID",
  adType: NativeAdType.NATIVE_AD,
  width: double.infinity,
  height: 300,
  backgroundColor: Colors.blue,
  titleColor: Colors.white,
  descriptionColor: Colors.white,
  buttonColor: Colors.deepPurple,
  buttonTitleColor: Colors.white,
  buttonBorderColor: Colors.white,
  listener: (result, value) {
    print("Native Ad: $result --> $value");
  },
),
```

### 7. Show Native Banner Ad:
Use `NativeBannerAdSize` to choose the height for Native banner ads. `height` property is ignored for native banner ads.

```dart
FacebookNativeAd(
  placementId: "YOUR_PLACEMENT_ID",
  adType: NativeAdType.NATIVE_BANNER_AD,
  bannerAdSize: NativeBannerAdSize.HEIGHT_100,
  width: double.infinity,
  backgroundColor: Colors.blue,
  titleColor: Colors.white,
  descriptionColor: Colors.white,
  buttonColor: Colors.deepPurple,
  buttonTitleColor: Colors.white,
  buttonBorderColor: Colors.white,
  listener: (result, value) {
    print("Native Ad: $result --> $value");
  },
),
```

**Check out the [example](https://github.com/dreamsoftin/facebook_audience_network/tree/master/example) for complete implementation.**

## Future Work
Implement for iOS platform.

