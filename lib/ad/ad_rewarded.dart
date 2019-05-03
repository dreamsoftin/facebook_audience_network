import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

enum RewardedVideoResult {
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
  static void Function(RewardedVideoResult, dynamic) _listener;

  static const _channel = const MethodChannel(REWARDED_VIDEO_CHANNEL);

  /// Loads a rewarded video Ad in background. Replace the default [placementId]
  /// with the one which you obtain by signing-up for Facebook Audience Network.
  ///
  /// [listener] passes [RewardedVideoResult] and information associated with
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
    Function(RewardedVideoResult, dynamic) listener,
  }) async {
    try {
      final args = <String, dynamic>{
        "id": placementId,
      };

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
  ///     if(result == RewardedVideoResult.LOADED)
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
          _listener(RewardedVideoResult.VIDEO_COMPLETE, call.arguments);
        break;
      case REWARDED_VIDEO_CLOSED_METHOD:
        if (_listener != null)
          _listener(RewardedVideoResult.VIDEO_CLOSED, call.arguments);
        break;
      case ERROR_METHOD:
        if (_listener != null)
          _listener(RewardedVideoResult.ERROR, call.arguments);
        break;
      case LOADED_METHOD:
        if (_listener != null)
          _listener(RewardedVideoResult.LOADED, call.arguments);
        break;
      case CLICKED_METHOD:
        if (_listener != null)
          _listener(RewardedVideoResult.CLICKED, call.arguments);
        break;
      case LOGGING_IMPRESSION_METHOD:
        if (_listener != null)
          _listener(RewardedVideoResult.LOGGING_IMPRESSION, call.arguments);
        break;
    }
    return Future.value(true);
  }
}
