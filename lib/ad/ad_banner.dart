import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

/// Defines the size of BannerAds. Only three ad sizes are supported. The width
/// is flexible with 320px as minimum.
///
/// There are three predefined sizes:
///
/// * [STANDARD] (320 * 50px)
/// * [LARGE] (320 * 90px)
/// * [MEDIUM_RECTANGLE] (320 * 250px)
class BannerSize {
  final int width;
  final int height;

  static const BannerSize STANDARD = BannerSize(width: 320, height: 50);
  static const BannerSize LARGE = BannerSize(width: 320, height: 90);
  static const BannerSize MEDIUM_RECTANGLE =
      BannerSize(width: 320, height: 250);

  const BannerSize({this.width = 320, this.height = 50});
}

enum BannerAdResult {
  /// Banner Ad error.
  ERROR,

  /// Banner Ad loaded successfully.
  LOADED,

  /// Banner Ad clicked.
  CLICKED,

  /// Banner Ad impression logged.
  LOGGING_IMPRESSION,
}

class FacebookBannerAd extends StatefulWidget {
  final Key key;

  /// Replace the default one with your placement ID for the release build.
  final String placementId;

  /// Size of the Banner Ad. Choose from three pre-defined sizes.
  final BannerSize bannerSize;

  /// Banner Ad listener
  final void Function(BannerAdResult, dynamic) listener;

  /// This defines if the ad view to be kept alive.
  final bool keepAlive;

  /// This widget is used to contain Banner Ads. [listener] is used to monitor
  /// Banner Ad. [BannerAdResult] is passed to the callback function along with
  /// other information based on result such as placement id, error code, error
  /// message, click info etc.
  ///
  /// Information will generally be of type Map with details such as:
  ///
  /// ```dart
  /// {
  ///   'placement\_id': "YOUR\_PLACEMENT\_ID",
  ///   'invalidated': false,
  ///   'error\_code': 2,
  ///   'error\_message': "No internet connection",
  /// }
  /// ```
  FacebookBannerAd({
    this.key,
    this.placementId = "YOUR_PLACEMENT_ID",
    this.bannerSize = BannerSize.STANDARD,
    this.listener,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  _FacebookBannerAdState createState() => _FacebookBannerAdState();
}

class _FacebookBannerAdState extends State<FacebookBannerAd>
    with AutomaticKeepAliveClientMixin {
  double containerHeight = 0.5;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        height: containerHeight,
        color: Colors.transparent,
        child: AndroidView(
          viewType: BANNER_AD_CHANNEL,
          onPlatformViewCreated: _onBannerAdViewCreated,
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "width": widget.bannerSize.width,
            "height": widget.bannerSize.height,
          },
          creationParamsCodec: StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        height: containerHeight,
        color: Colors.transparent,
        child: Container(
          width: widget.bannerSize.width.toDouble(),
          child: Center(
            child: UiKitView(
              viewType: BANNER_AD_CHANNEL,
              onPlatformViewCreated: _onBannerAdViewCreated,
              creationParams: <String, dynamic>{
                "id": widget.placementId,
                "width": widget.bannerSize.width,
                "height": widget.bannerSize.height,
              },
              creationParamsCodec: StandardMessageCodec(),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: widget.bannerSize.height <= -1
            ? double.infinity
            : widget.bannerSize.height.toDouble(),
        child: Center(
          child:
              Text("Banner Ads for this platform is currently not supported"),
        ),
      );
    }
  }

  void _onBannerAdViewCreated(int id) async {
    final channel = MethodChannel('${BANNER_AD_CHANNEL}_$id');
    
    channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case ERROR_METHOD:
          if (widget.listener != null)
            widget.listener(BannerAdResult.ERROR, call.arguments);
          break;
        case LOADED_METHOD:
          setState(() {
            containerHeight = widget.bannerSize.height <= -1
                ? double.infinity
                : widget.bannerSize.height.toDouble();
          });
          if (widget.listener != null)
            widget.listener(BannerAdResult.LOADED, call.arguments);
          break;
        case CLICKED_METHOD:
          if (widget.listener != null)
            widget.listener(BannerAdResult.CLICKED, call.arguments);
          break;
        case LOGGING_IMPRESSION_METHOD:
          if (widget.listener != null)
            widget.listener(BannerAdResult.LOGGING_IMPRESSION, call.arguments);
          break;
      }
    });
  }
}
