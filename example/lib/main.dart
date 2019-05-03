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
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6",
    );
    _videoComplete = false;
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
        if (result == RewardedVideoAdResult.LOADED)
          FacebookRewardedVideoAd.showRewardedVideoAd();
        if (result == RewardedVideoAdResult.VIDEO_COMPLETE)
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
        body: Stack(
          children: <Widget>[
            _videoComplete == false
                ? Container(
                    alignment: Alignment(0.5, -1.0),
                    child: FacebookInStreamVideoAd(
                      placementId: "YOUR_PLACEMENT_ID",
                      height: 300,
                      listener: (result, value) {
                        if (result == InStreamVideoAdResult.VIDEO_COMPLETE) {
                          setState(() {
                            _videoComplete = true;
                          });
                        }
                      },
                    ),
                  )
                : SizedBox(
                    width: 0,
                    height: 0,
                  ),
            Container(
              alignment: Alignment(0.5, 1),
              child: FacebookBannerAd(
                bannerSize: BannerSize.STANDARD,
                listener: (result, value) {
                  print("Banner Ad: $result --> $value");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
