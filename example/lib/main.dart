import 'package:flutter/material.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _videoComplete = false;

  @override
  void initState() {
    super.initState();
    FacebookAudienceNetwork.init(
      testingId: "de650e48-8d5d-4561-8409-558ef490e303",
    );
    _videoComplete = false;

    /*FacebookInterstitialAd.loadInterstitialAd(
      placementId: "YOUR_PLACEMENT_ID",
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED)
          FacebookInterstitialAd.showInterstitialAd();
      },
    );

    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: "YOUR_PLACEMENT_ID",
      listener: (result, value) {
        if (result == RewardedVideoAdResult.LOADED)
          FacebookRewardedVideoAd.showRewardedVideoAd();
        if (result == RewardedVideoAdResult.VIDEO_COMPLETE)
          print("Video completed");
      },
    );*/
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
        body: FacebookNativeAd(
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
      ),
    );
  }
}
