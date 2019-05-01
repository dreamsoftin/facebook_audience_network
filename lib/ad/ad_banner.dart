import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BannerSize {
  final int width;
  final int height;

  static const BannerSize STANDARD = BannerSize(width: 320, height: 50);
  static const BannerSize LARGE = BannerSize(width: 320, height: 90);
  static const BannerSize MEDIUM_RECTANGLE = BannerSize(width: 320, height: 250);

  const BannerSize({this.width=320, this.height=50});
}

enum AdResult {
  ERROR,
  SUCCESS,
  CLICKED,
  LOGGING_IMPRESSION,
}

class FacebookBannerAd extends StatefulWidget {
  final BannerSize bannerSize;
  final void Function(AdResult, dynamic) listener;

  FacebookBannerAd({
    this.bannerSize = BannerSize.STANDARD,
    this.listener,
  });

  @override
  _FacebookBannerAdState createState() => _FacebookBannerAdState();
}

class _FacebookBannerAdState extends State<FacebookBannerAd> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        height: widget.bannerSize.height <= -1
            ? double.infinity
            : widget.bannerSize.height.toDouble(),
        child: AndroidView(
          viewType: 'fb.audience.network.io/bannerAd',
          onPlatformViewCreated: _onBannerAdViewCreated,
          creationParams: <String, dynamic>{
            "width": widget.bannerSize.width,
            "height": widget.bannerSize.height,
          },
          creationParamsCodec: StandardMessageCodec(),
        ),
      );
    } else {
      //TODO: Implement BannerAd for iOS once supported.
      return Container(
        height: widget.bannerSize.height <= -1
            ? double.infinity
            : widget.bannerSize.height.toDouble(),
        child: Center(
          child: Text("BannerAds for iOS is currently not supported"),
        ),
      );
    }
  }

  void _onBannerAdViewCreated(int id) async {
    final channel = MethodChannel('fb.audience.network.io/bannerAd_$id');

    if (widget.listener != null) {
      channel.setMethodCallHandler((MethodCall call) {
        switch (call.method) {
          case "error":
            widget.listener(AdResult.ERROR, call.arguments);
            break;
          case "success":
            widget.listener(AdResult.SUCCESS, call.arguments);
            break;
          case "clicked":
            widget.listener(AdResult.CLICKED, call.arguments);
            break;
          case "logging_impression":
            widget.listener(AdResult.LOGGING_IMPRESSION, call.arguments);
            break;
        }
      });
    }
  }
}
