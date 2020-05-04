import 'dart:io';

import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

enum RewardedVideoAdResult {
  /// Rewarded video error.
  ERROR,

  /// Rewarded video loaded successfully.
  LOADED,

  /// Rewarded video clicked.
  CLICKED,

  /// Rewarded video impression logged.
  LOGGING_IMPRESSION,

  /// Rewarded video played till the end. Use it to reward the user.
  VIDEO_COMPLETE,

  /// Rewarded video closed.
  VIDEO_CLOSED,
}

class FacebookRewardedVideoAd {
  static void Function(RewardedVideoAdResult, dynamic) _listener;

  static const _channel = const MethodChannel(REWARDED_VIDEO_CHANNEL);

  /// Loads a rewarded video Ad in background. Replace the default [placementId]
  /// with the one which you obtain by signing-up for Facebook Audience Network.
  ///
  /// [listener] passes [RewardedVideoAdResult] and information associated with
  /// the result to the implemented callback.
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
  static Future<bool> loadRewardedVideoAd({
    String placementId = "YOUR_PLACEMENT_ID",
    Function(RewardedVideoAdResult, dynamic) listener,
  }) async {
    try {
      final args = <String, dynamic>{
        "id": placementId,
      };
      
      if(Platform.isIOS)
        return false;

      final result = await _channel.invokeMethod(
        LOAD_REWARDED_VIDEO_METHOD,
        args,
      );
      _channel.setMethodCallHandler(_rewardedMethodCall);
      _listener = listener;

      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Shows a rewarded video Ad after it has been loaded. (This needs to be
  /// called only after calling [loadRewardedVideoAd] function). [delay] is in
  /// milliseconds.
  ///
  /// Example:
  ///
  /// ```dart
  /// FacebookRewardedVideoAd.loadRewardedVideoAd(
  ///   listener: (result, value) {
  ///     if(result == RewardedVideoAdResult.LOADED)
  ///       FacebookRewardedVideoAd.showRewardedVideoAd();
  ///   },
  /// );
  /// ```
  static Future<bool> showRewardedVideoAd({int delay = 0}) async {
    try {
      final args = <String, dynamic>{
        "delay": delay,
      };

      final result = await _channel.invokeMethod(
        SHOW_REWARDED_VIDEO_METHOD,
        args,
      );

      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Removes the rewarded video Ad.
  static Future<bool> destroyRewardedVideoAd() async {
    try {
      final result = await _channel.invokeMethod(DESTROY_REWARDED_VIDEO_METHOD);
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<dynamic> _rewardedMethodCall(MethodCall call) {
    switch (call.method) {
      case REWARDED_VIDEO_COMPLETE_METHOD:
        if (_listener != null)
          _listener(RewardedVideoAdResult.VIDEO_COMPLETE, call.arguments);
        break;
      case REWARDED_VIDEO_CLOSED_METHOD:
        if (_listener != null)
          _listener(RewardedVideoAdResult.VIDEO_CLOSED, call.arguments);
        break;
      case ERROR_METHOD:
        if (_listener != null)
          _listener(RewardedVideoAdResult.ERROR, call.arguments);
        break;
      case LOADED_METHOD:
        if (_listener != null)
          _listener(RewardedVideoAdResult.LOADED, call.arguments);
        break;
      case CLICKED_METHOD:
        if (_listener != null)
          _listener(RewardedVideoAdResult.CLICKED, call.arguments);
        break;
      case LOGGING_IMPRESSION_METHOD:
        if (_listener != null)
          _listener(RewardedVideoAdResult.LOGGING_IMPRESSION, call.arguments);
        break;
    }
    return Future.value(true);
  }
}
