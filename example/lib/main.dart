import 'package:flutter/material.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    FacebookAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6",
    );
    super.initState();
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
              print("Facebook Banner Ad Result: $result Value: $value");
            },
          ),
        ),
      ),
    );
  }
}
