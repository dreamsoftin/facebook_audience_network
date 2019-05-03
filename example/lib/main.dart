import 'package:flutter/material.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool showBannerAd = true;

  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6",
    );

    FacebookInterstitialAd.loadInterstitialAd(
      placementId: "YOUR_PLACEMENT_ID",
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED)
          FacebookInterstitialAd.showInterstitialAd();
      },
    );

    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: "YOUR_PLACEMENT_ID",
      listener: (result, value) {
        if(result == RewardedVideoResult.LOADED)
          FacebookRewardedVideoAd.showRewardedVideoAd();
        if(result == RewardedVideoResult.VIDEO_COMPLETE)
          print("Video completed");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    FacebookAudienceNetwork.destroyInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "FB Audience Network Example",
          ),
        ),
        body: Container(
          alignment: Alignment(0.5, 1),
          child: FacebookBannerAd(
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
        ),
      ),
    );
  }
}
