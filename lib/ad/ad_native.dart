import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

class FacebookNativeAdBuilder extends StatefulWidget {
  final String placementId;
  final Widget Function(Map<String, dynamic>) onLoaded;

  FacebookNativeAdBuilder({
    this.placementId = "YOUR_PLACEMENT_ID",
    @required this.onLoaded,
  });

  @override
  _FaceBookNativeAdState createState() => _FaceBookNativeAdState();
}

class _FaceBookNativeAdState extends State<FacebookNativeAdBuilder> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      //TODO: Implement NativeAd builder
      return Container(
        child: AndroidView(
          viewType: NATIVE_AD_CHANNEL,
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParams: <String, dynamic>{
            "id": widget.placementId,
          },
          creationParamsCodec: StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      //TODO: Implement NativeAd for iOS once supported.
      return Container(
        child: Center(
          child: Text("BannerAds for iOS is currently not supported"),
        ),
      );
    } else {
      return Container(
        child: Center(
          child: Text("BannerAds for this platform is currently not supported"),
        ),
      );
    }
  }

  void _onNativeAdViewCreated(int id) {}
}
