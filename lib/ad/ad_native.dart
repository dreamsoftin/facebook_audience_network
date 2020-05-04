import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

enum NativeAdType {
  /// Customizable Native Ad.
  NATIVE_AD,

  /// Customizable Native Banner Ad.
  NATIVE_BANNER_AD,
}

enum NativeAdResult {
  /// Native Ad error.
  ERROR,

  /// Native Ad loaded successfully.
  LOADED,

  /// Native Ad clicked.
  CLICKED,

  /// Native Ad impression logged.
  LOGGING_IMPRESSION,

  /// Native Ad media loaded successfully.
  MEDIA_DOWNLOADED,
}

/// Defines the size of Native Banner Ads. Only three ad sizes are supported.
/// The width is flexible with predefined heights as follow:
///
/// * [HEIGHT_50] (Includes: Icon, Title, Context and CTA button)
/// * [HEIGHT_100] (Includes: Icon, Title, Context and CTA button)
/// * [HEIGHT_120] (Includes: Icon, Title, Context, Description and CTA button)
class NativeBannerAdSize {
  final int height;

  static const NativeBannerAdSize HEIGHT_50 = NativeBannerAdSize(height: 50);
  static const NativeBannerAdSize HEIGHT_100 = NativeBannerAdSize(height: 100);
  static const NativeBannerAdSize HEIGHT_120 = NativeBannerAdSize(height: 120);

  const NativeBannerAdSize({this.height});
}

class FacebookNativeAd extends StatefulWidget {
  /// Replace the default one with your placement ID for the release build.
  final String placementId;

  /// Native Ad listener.
  final void Function(NativeAdResult, dynamic) listener;

  /// Choose between [NativeAdType.NATIVE_AD] and
  /// [NativeAdType.NATIVE_BANNER_AD]
  final NativeAdType adType;

  /// If [adType] is [NativeAdType.NATIVE_BANNER_AD] you can choose between
  /// three predefined Ad sizes.
  final NativeBannerAdSize bannerAdSize;

  /// Recommended width is between **280-500** for Native Ads. You can use
  /// [double.infinity] as the width to match the parent widget width.
  final double width;

  /// Recommended width is between **250-500** for Native Ads. Native Banner Ad
  /// height is predefined in [bannerAdSize] and cannot be
  /// changed through this parameter.
  final double height;

  /// This defines the background color of the Native Ad.
  final Color backgroundColor;

  /// This defines the title text color of the Native Ad.
  final Color titleColor;

  /// This defines the description text color of the Native Ad.
  final Color descriptionColor;

  /// This defines the button color of the Native Ad.
  final Color labelColor;

  /// This defines the button color of the Native Ad.
  final Color buttonColor;

  /// This defines the button text color of the Native Ad.
  final Color buttonTitleColor;

  /// This defines the button border color of the Native Ad.
  final Color buttonBorderColor;

  final bool isMediaCover;

  /// This defines if the ad view to be kept alive.
  final bool keepAlive;

  /// This defines if the ad view should be collapsed while loading
  final bool keepExpanedWhileLoading;

  /// Expand animation duration in milliseconds
  final int expandAnimationDuraion;

  /// This widget can be used to display customizable native ads and native
  /// banner ads.
  FacebookNativeAd({
    Key key,
    this.placementId = "YOUR_PLACEMENT_ID",
    this.listener,
    @required this.adType,
    this.bannerAdSize = NativeBannerAdSize.HEIGHT_50,
    this.width = double.infinity,
    this.height = 250,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.labelColor,
    this.buttonColor,
    this.buttonTitleColor,
    this.buttonBorderColor,
    this.isMediaCover = false,
    this.keepAlive = false,
    this.keepExpanedWhileLoading = true,
    this.expandAnimationDuraion = 0,
  }) : super(key: key);

  @override
  _FacebookNativeAdState createState() => _FacebookNativeAdState();
}

class _FacebookNativeAdState extends State<FacebookNativeAd>
    with AutomaticKeepAliveClientMixin {
  double containerHeight = 0.5;
  bool isAdReady = false;
  @override
  bool get wantKeepAlive => widget.keepAlive;

  String _getChannelRegisterId() {
    String channel = NATIVE_AD_CHANNEL;
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        widget.adType == NativeAdType.NATIVE_BANNER_AD) {
      channel = NATIVE_BANNER_AD_CHANNEL;
    }
    return channel;
  }

  Widget build(BuildContext context) {
    return AnimatedContainer(
      color: Colors.transparent,
      width: widget.width,
      height: isAdReady || widget.keepExpanedWhileLoading ? widget.height : 0.1,
      duration: Duration(milliseconds: widget.expandAnimationDuraion),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: isAdReady || widget.keepExpanedWhileLoading ? 0 : -(widget.height - 0.1),
            child: ConstrainedBox(
              constraints: new BoxConstraints(
                maxHeight: widget.width,
                maxWidth: widget.width == double.infinity
                    ? MediaQuery.of(context).size.width
                    : widget.width,
              ),
              child: buildPlatformView(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build2(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.width,
        height: widget.adType == NativeAdType.NATIVE_AD
            ? (isAdReady
                ? widget.height
                : widget.keepExpanedWhileLoading ? containerHeight : widget.height)
            : widget.bannerAdSize.height.toDouble(),
        child: AndroidView(
          viewType: NATIVE_AD_CHANNEL,
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "banner_ad":
                widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
            // height param is only for Banner Ads. Native Ad's height is
            // governed by container.
            "height": widget.bannerAdSize.height,
            "bg_color": widget.backgroundColor == null
                ? null
                : _getHexStringFromColor(widget.backgroundColor),
            "title_color": widget.titleColor == null
                ? null
                : _getHexStringFromColor(widget.titleColor),
            "desc_color": widget.descriptionColor == null
                ? null
                : _getHexStringFromColor(widget.descriptionColor),
            "label_color": widget.labelColor == null
                ? null
                : _getHexStringFromColor(widget.labelColor),
            "button_color": widget.buttonColor == null
                ? null
                : _getHexStringFromColor(widget.buttonColor),
            "button_title_color": widget.buttonTitleColor == null
                ? null
                : _getHexStringFromColor(widget.buttonTitleColor),
            "button_border_color": widget.buttonBorderColor == null
                ? null
                : _getHexStringFromColor(widget.buttonBorderColor),
          },
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        color: Colors.red,
        height: 500,
        width: 500,
        child: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            Positioned(
              bottom: -250,
              child: ConstrainedBox(
                constraints: new BoxConstraints(
                  maxHeight: 300.0,
                  maxWidth: 300.0,
                ),
                child: UiKitView(
                  viewType: _getChannelRegisterId(),
                  onPlatformViewCreated: _onNativeAdViewCreated,
                  creationParamsCodec: StandardMessageCodec(),
                  creationParams: <String, dynamic>{
                    "id": widget.placementId,
                    "ad_type": widget.adType.index,
                    "banner_ad": widget.adType == NativeAdType.NATIVE_BANNER_AD
                        ? true
                        : false,
                    "height": widget.adType == NativeAdType.NATIVE_BANNER_AD
                        ? widget.bannerAdSize.height
                        : widget.height,
                    "bg_color": widget.backgroundColor == null
                        ? null
                        : _getHexStringFromColor(widget.backgroundColor),
                    "title_color": widget.titleColor == null
                        ? null
                        : _getHexStringFromColor(widget.titleColor),
                    "desc_color": widget.descriptionColor == null
                        ? null
                        : _getHexStringFromColor(widget.descriptionColor),
                    "label_color": widget.labelColor == null
                        ? null
                        : _getHexStringFromColor(widget.labelColor),
                    "button_color": widget.buttonColor == null
                        ? null
                        : _getHexStringFromColor(widget.buttonColor),
                    "button_title_color": widget.buttonTitleColor == null
                        ? null
                        : _getHexStringFromColor(widget.buttonTitleColor),
                    "button_border_color": widget.buttonBorderColor == null
                        ? null
                        : _getHexStringFromColor(widget.buttonBorderColor),
                    "is_media_cover": widget.isMediaCover,
                  },
                ),
              ),
            ),
          ],
        ),
      );

      return Container(
        width: widget.width,
        color: Colors.red,
        alignment: Alignment.bottomCenter,
        height: (widget.adType == NativeAdType.NATIVE_BANNER_AD)
            ? widget.bannerAdSize.height.toDouble()
            : isAdReady
                ? widget.height
                : widget
                    .height, //widget.collapseWhileLoading ? containerHeight : widget.height,
        child: FractionallySizedBox(
          heightFactor: 1,
          child: UiKitView(
            viewType: _getChannelRegisterId(),
            onPlatformViewCreated: _onNativeAdViewCreated,
            creationParamsCodec: StandardMessageCodec(),
            creationParams: <String, dynamic>{
              "id": widget.placementId,
              "ad_type": widget.adType.index,
              "banner_ad":
                  widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
              "height": widget.adType == NativeAdType.NATIVE_BANNER_AD
                  ? widget.bannerAdSize.height
                  : widget.height,
              "bg_color": widget.backgroundColor == null
                  ? null
                  : _getHexStringFromColor(widget.backgroundColor),
              "title_color": widget.titleColor == null
                  ? null
                  : _getHexStringFromColor(widget.titleColor),
              "desc_color": widget.descriptionColor == null
                  ? null
                  : _getHexStringFromColor(widget.descriptionColor),
              "label_color": widget.labelColor == null
                  ? null
                  : _getHexStringFromColor(widget.labelColor),
              "button_color": widget.buttonColor == null
                  ? null
                  : _getHexStringFromColor(widget.buttonColor),
              "button_title_color": widget.buttonTitleColor == null
                  ? null
                  : _getHexStringFromColor(widget.buttonTitleColor),
              "button_border_color": widget.buttonBorderColor == null
                  ? null
                  : _getHexStringFromColor(widget.buttonBorderColor),
              "is_media_cover": widget.isMediaCover,
            },
          ),
        ),
      );
    } else {
      return Container(
        width: widget.width,
        height: widget.height,
        child: Text("Banner Ads for this platform is currently not supported"),
      );
    }
  }

  Widget buildPlatformView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.width,
        height: widget.adType == NativeAdType.NATIVE_AD
            ? (isAdReady
                ? widget.height
                : widget.keepExpanedWhileLoading ? containerHeight : widget.height)
            : widget.bannerAdSize.height.toDouble(),
        child: AndroidView(
          viewType: NATIVE_AD_CHANNEL,
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "banner_ad":
                widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
            // height param is only for Banner Ads. Native Ad's height is
            // governed by container.
            "height": widget.bannerAdSize.height,
            "bg_color": widget.backgroundColor == null
                ? null
                : _getHexStringFromColor(widget.backgroundColor),
            "title_color": widget.titleColor == null
                ? null
                : _getHexStringFromColor(widget.titleColor),
            "desc_color": widget.descriptionColor == null
                ? null
                : _getHexStringFromColor(widget.descriptionColor),
            "label_color": widget.labelColor == null
                ? null
                : _getHexStringFromColor(widget.labelColor),
            "button_color": widget.buttonColor == null
                ? null
                : _getHexStringFromColor(widget.buttonColor),
            "button_title_color": widget.buttonTitleColor == null
                ? null
                : _getHexStringFromColor(widget.buttonTitleColor),
            "button_border_color": widget.buttonBorderColor == null
                ? null
                : _getHexStringFromColor(widget.buttonBorderColor),
          },
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ConstrainedBox(
        constraints: new BoxConstraints(
          maxWidth: widget.width,
          maxHeight: widget.adType == NativeAdType.NATIVE_AD
              ? widget.height
              : widget.bannerAdSize.height.toDouble(),
        ),
        child: UiKitView(
          viewType: _getChannelRegisterId(),
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "ad_type": widget.adType.index,
            "banner_ad":
                widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
            "height": widget.adType == NativeAdType.NATIVE_BANNER_AD
                ? widget.bannerAdSize.height
                : widget.height,
            "bg_color": widget.backgroundColor == null
                ? null
                : _getHexStringFromColor(widget.backgroundColor),
            "title_color": widget.titleColor == null
                ? null
                : _getHexStringFromColor(widget.titleColor),
            "desc_color": widget.descriptionColor == null
                ? null
                : _getHexStringFromColor(widget.descriptionColor),
            "label_color": widget.labelColor == null
                ? null
                : _getHexStringFromColor(widget.labelColor),
            "button_color": widget.buttonColor == null
                ? null
                : _getHexStringFromColor(widget.buttonColor),
            "button_title_color": widget.buttonTitleColor == null
                ? null
                : _getHexStringFromColor(widget.buttonTitleColor),
            "button_border_color": widget.buttonBorderColor == null
                ? null
                : _getHexStringFromColor(widget.buttonBorderColor),
            "is_media_cover": widget.isMediaCover,
          },
        ),
      );
    }
  }

  String _getHexStringFromColor(Color color) =>
      '#${color.value.toRadixString(16)}';

  void _onNativeAdViewCreated(int id) {
    final channel = MethodChannel('${NATIVE_AD_CHANNEL}_$id');

    channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case ERROR_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.ERROR, call.arguments);
          break;
        case LOADED_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.LOADED, call.arguments);

          if (!isAdReady) {
            Future.delayed(Duration(seconds: 0)).then((value) {
              setState(() {
                isAdReady = true;
              });
            });
          }

          /// ISSUE: Changing height on Ad load causes the ad button to not work
          /*setState(() {
            containerHeight = widget.height;
          });*/
          break;
        case LOAD_SUCCESS_METHOD:
          if (!isAdReady) {
            setState(() {
              isAdReady = true;
            });
          }
          break;
        case CLICKED_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.CLICKED, call.arguments);
          break;
        case LOGGING_IMPRESSION_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.LOGGING_IMPRESSION, call.arguments);
          break;
        case MEDIA_DOWNLOADED_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.MEDIA_DOWNLOADED, call.arguments);
          break;
      }
    });
  }
}
