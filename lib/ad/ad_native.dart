import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

enum NativeAdType {
  /// Customizable Native Ad.
  NATIVE_AD,

  /// Customizable Native Banner Ad.
  NATIVE_BANNER_AD,
  //ios Only
  NATIVE_AD_HORIZONTAL,
  NATIVE_AD_VERTICAL,
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
  final int? height;

  static const NativeBannerAdSize HEIGHT_50 = NativeBannerAdSize(height: 50);
  static const NativeBannerAdSize HEIGHT_100 = NativeBannerAdSize(height: 100);
  static const NativeBannerAdSize HEIGHT_120 = NativeBannerAdSize(height: 120);

  const NativeBannerAdSize({this.height});
}

class FacebookNativeAd extends StatefulWidget {
  /// Replace the default one with your placement ID for the release build.
  final String placementId;

  /// Native Ad listener.
  final void Function(NativeAdResult, dynamic)? listener;

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
  final Color? backgroundColor;

  /// This defines the title text color of the Native Ad.
  final Color? titleColor;

  /// This defines the description text color of the Native Ad.
  final Color? descriptionColor;

  /// This defines the button color of the Native Ad.
  final Color? labelColor;

  /// This defines the button color of the Native Ad.
  final Color? buttonColor;

  /// This defines the button text color of the Native Ad.
  final Color? buttonTitleColor;

  /// This defines the button border color of the Native Ad.
  final Color? buttonBorderColor;

  final bool isMediaCover;

  /// This defines if the ad view to be kept alive.
  final bool keepAlive;

  /// This defines if the ad view should be collapsed while loading
  final bool keepExpandedWhileLoading;

  /// Expand animation duration in milliseconds
  final int expandAnimationDuraion;

  /// This widget can be used to display customizable native ads and native
  /// banner ads.
  FacebookNativeAd({
    Key? key,
    this.placementId = "YOUR_PLACEMENT_ID",
    this.listener,
    required this.adType,
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
    this.keepExpandedWhileLoading = true,
    this.expandAnimationDuraion = 0,
  }) : super(key: key);

  @override
  _FacebookNativeAdState createState() => _FacebookNativeAdState();
}

class _FacebookNativeAdState extends State<FacebookNativeAd> with AutomaticKeepAliveClientMixin {
  final double containerHeight = Platform.isAndroid ? 1.0 : 0.1;
  bool isAdReady = false;
  @override
  bool get wantKeepAlive => widget.keepAlive;

  String _getChannelRegisterId() {
    String channel = NATIVE_AD_CHANNEL;
    if (defaultTargetPlatform == TargetPlatform.iOS && widget.adType == NativeAdType.NATIVE_BANNER_AD) {
      channel = NATIVE_BANNER_AD_CHANNEL;
    }
    return channel;
  }

  Widget build(BuildContext context) {
    super.build(context);
    double width = widget.width == double.infinity ? MediaQuery.of(context).size.width : widget.width;
    return AnimatedContainer(
      color: Colors.transparent,
      width: width,
      height: isAdReady || widget.keepExpandedWhileLoading ? widget.height : containerHeight,
      duration: Duration(milliseconds: widget.expandAnimationDuraion),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            top: isAdReady || widget.keepExpandedWhileLoading ? 0 : -(widget.height - containerHeight),
            child: ConstrainedBox(
              constraints: new BoxConstraints(
                maxHeight: widget.height,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: buildPlatformView(width),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlatformView(double width) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "id": widget.placementId,
      "ad_type": widget.adType.index,
      "banner_ad": widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
      "height": widget.adType == NativeAdType.NATIVE_BANNER_AD ? widget.bannerAdSize.height : widget.height,
      "bg_color": widget.backgroundColor == null ? null : _getHexStringFromColor(widget.backgroundColor!),
      "title_color": widget.titleColor == null ? null : _getHexStringFromColor(widget.titleColor!),
      "desc_color": widget.descriptionColor == null ? null : _getHexStringFromColor(widget.descriptionColor!),
      "label_color": widget.labelColor == null ? null : _getHexStringFromColor(widget.labelColor!),
      "button_color": widget.buttonColor == null ? null : _getHexStringFromColor(widget.buttonColor!),
      "button_title_color": widget.buttonTitleColor == null ? null : _getHexStringFromColor(widget.buttonTitleColor!),
      "button_border_color":
          widget.buttonBorderColor == null ? null : _getHexStringFromColor(widget.buttonBorderColor!),
      "is_media_cover": widget.isMediaCover,
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: width,
        height: widget.adType == NativeAdType.NATIVE_AD ||
                widget.adType == NativeAdType.NATIVE_AD_HORIZONTAL ||
                widget.adType == NativeAdType.NATIVE_AD_VERTICAL
            ? widget.height
            : widget.bannerAdSize.height!.toDouble(),
        child: PlatformViewLink(
          viewType: NATIVE_AD_CHANNEL,
          surfaceFactory: (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: NATIVE_AD_CHANNEL,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(_onNativeAdViewCreated)
              ..create();
          },
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        width: width,
        height: widget.adType == NativeAdType.NATIVE_AD ? widget.height : widget.bannerAdSize.height!.toDouble(),
        child: UiKitView(
          viewType: _getChannelRegisterId(),
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: creationParams,
        ),
      );
    } else {
      return Container(
        width: width,
        height: widget.height,
        child: Text("Native Ads for this platform is currently not supported"),
      );
    }
  }

  String _getHexStringFromColor(Color color) => '#${color.value.toRadixString(16)}';

  void _onNativeAdViewCreated(int id) {
    final channel = MethodChannel('${NATIVE_AD_CHANNEL}_$id');

    channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case ERROR_METHOD:
          if (widget.listener != null) widget.listener!(NativeAdResult.ERROR, call.arguments);
          break;
        case LOADED_METHOD:
          if (widget.listener != null) widget.listener!(NativeAdResult.LOADED, call.arguments);

          if (!isAdReady) {
            setState(() {
              isAdReady = true;
            });
          }

          /// ISSUE: Changing height on Ad load causes the ad button to not work
          /*setState(() {
            containerHeight = widget.height;
          });*/
          break;
        case LOAD_SUCCESS_METHOD:
          if (!mounted) Future<dynamic>.value(true);
          if (!isAdReady) {
            setState(() {
              isAdReady = true;
            });
          }
          break;
        case CLICKED_METHOD:
          if (widget.listener != null) widget.listener!(NativeAdResult.CLICKED, call.arguments);
          break;
        case LOGGING_IMPRESSION_METHOD:
          if (widget.listener != null) widget.listener!(NativeAdResult.LOGGING_IMPRESSION, call.arguments);
          break;
        case MEDIA_DOWNLOADED_METHOD:
          if (widget.listener != null) widget.listener!(NativeAdResult.MEDIA_DOWNLOADED, call.arguments);
          break;
      }

      return Future<dynamic>.value(true);
    });
  }
}
