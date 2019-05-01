import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FacebookNativeAd extends StatefulWidget {
  final width;
  final height;

  FacebookNativeAd({this.width, this.height});

  @override
  _FaceBookNativeAdState createState() => _FaceBookNativeAdState();
}

class _FaceBookNativeAdState extends State<FacebookNativeAd> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.width,
        height: widget.height,
        child: AndroidView(
          viewType: 'fb.audience.network.io/nativeAd',
          onPlatformViewCreated: _onNativeAdViewCreated,

        ),
      );
    } else {
      //TODO: Implement NativeAd for iOS once supported.
      return Container(
        width: widget.width,
        height: widget.height,
        child: Text("NativeAds for iOS is currently not supported"),
      );
    }
  }

  void _onNativeAdViewCreated(int id) {

  }
}