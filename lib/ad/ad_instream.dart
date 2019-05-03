import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

enum InStreamVideoAdResult {
  /// InStream video ad error.
  ERROR,

  /// InStream video ad loaded successfully.
  LOADED,

  /// InStream video ad played till the end by user.
  VIDEO_COMPLETE,

  /// InStream video ad clicked.
  CLICKED,

  /// InStream video ad impression logged.
  LOGGING_IMPRESSION,
}

class FacebookInStreamVideoAd extends StatefulWidget {
  final Key key;
  final String placementId;
  final double width;
  final double height;
  final void Function(InStreamVideoAdResult, dynamic) listener;

  FacebookInStreamVideoAd({
    this.key,
    this.placementId = "YOUR_PLACEMENT_ID",
    this.width=double.infinity,
    @required this.height,
    this.listener,
  }) : super(key: key);

  @override
  _FacebookInStreamVideoAdState createState() =>
      _FacebookInStreamVideoAdState();
}

class _FacebookInStreamVideoAdState extends State<FacebookInStreamVideoAd> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.width,
        height: widget.height == double.infinity
            ? MediaQuery.of(context).size.height
            : widget.height,
        color: Colors.transparent,
        child: Center(
          child: AndroidView(
            viewType: IN_STREAM_VIDEO_CHANNEL,
            onPlatformViewCreated: _onInStreamVideoAdViewCreated,
            creationParams: <String, dynamic>{
              "id": widget.placementId,
              "width": widget.width == double.infinity
                  ? MediaQuery.of(context).size.width.toInt()
                  : widget.width.toInt(),
              "height": widget.height == double.infinity
                  ? MediaQuery.of(context).size.height.toInt()
                  : widget.height.toInt(),
            },
            creationParamsCodec: StandardMessageCodec(),
          ),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      //TODO: Implement BannerAd for iOS once supported.
      return Container(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Text("BannerAds for iOS is currently not supported"),
        ),
      );
    } else {
      return Container(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Text("BannerAds for this platform is currently not supported"),
        ),
      );
    }
  }

  void _onInStreamVideoAdViewCreated(int id) {
    final channel = MethodChannel('${IN_STREAM_VIDEO_CHANNEL}_$id');

    channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case ERROR_METHOD:
          if (widget.listener != null)
            widget.listener(InStreamVideoAdResult.ERROR, call.arguments);
          break;
        case LOADED_METHOD:
          if (widget.listener != null)
            widget.listener(InStreamVideoAdResult.LOADED, call.arguments);
          break;
        case IN_STREAM_VIDEO_COMPLETE_METHOD:
          if (widget.listener != null)
            widget.listener(
                InStreamVideoAdResult.VIDEO_COMPLETE, call.arguments);
          break;
        case CLICKED_METHOD:
          if (widget.listener != null)
            widget.listener(InStreamVideoAdResult.CLICKED, call.arguments);
          break;
        case LOGGING_IMPRESSION_METHOD:
          if (widget.listener != null)
            widget.listener(
                InStreamVideoAdResult.LOGGING_IMPRESSION, call.arguments);
          break;
      }
    });
  }
}
