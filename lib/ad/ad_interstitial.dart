import 'dart:io';

import 'package:flutter/services.dart';

import 'package:facebook_audience_network/constants.dart';

enum InterstitialAdResult {
  /// Interstitial Ad displayed to the user
  DISPLAYED,

  /// Interstitial Ad dismissed by the user
  DISMISSED,

  /// Interstitial Ad error
  ERROR,

  /// Interstitial Ad loaded
  LOADED,

  /// Interstitial Ad clicked
  CLICKED,

  /// Interstitial Ad impression logged
  LOGGING_IMPRESSION,
}

class FacebookInterstitialAd {
  static void Function(InterstitialAdResult, dynamic) _listener;

  static final _channel =  MethodChannel(Platform.isIOS ? MAIN_CHANNEL : INTERSTITIAL_AD_CHANNEL);

  /// Loads an Interstitial Ad in background. Replace the default [placementId]
  /// with the one which you obtain by signing-up for Facebook Audience Network.
  ///
  /// [listener] passes [InterstitialAdResult] and information associated with
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
  static Future<bool> loadInterstitialAd({
    String placementId = "YOUR_PLACEMENT_ID",
    Function(InterstitialAdResult, dynamic) listener,
  }) async {
    try {
      final args = <String, dynamic>{
        "id": placementId,
      };

      final result = await _channel.invokeMethod(
        LOAD_INTERSTITIAL_METHOD,
        args,
      );
      _channel.setMethodCallHandler(_interstitialMethodCall);
      _listener = listener;

      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Shows an Interstitial Ad after it has been loaded. (This needs to be called
  /// only after calling [loadInterstitialAd] function). [delay] is in
  /// milliseconds.
  ///
  /// Example:
  ///
  /// ```dart
  /// FacebookInterstitialAd.loadInterstitialAd(
  ///   listener: (result, value) {
  ///     if (result == InterstitialAdResult.LOADED)
  ///       FacebookInterstitialAd.showInterstitialAd(delay: 5000);
  ///   },
  /// );
  /// ```
  static Future<bool> showInterstitialAd({int delay = 0}) async {
    try {
      final args = <String, dynamic>{
        "delay": delay,
      };

      final result = await _channel.invokeMethod(
        SHOW_INTERSTITIAL_METHOD,
        args,
      );

      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Removes the Ad.
  static Future<bool> destroyInterstitialAd() async {
    try {
      final result = await _channel.invokeMethod(DESTROY_INTERSTITIAL_METHOD);
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<dynamic> _interstitialMethodCall(MethodCall call) {
    switch (call.method) {
      case DISPLAYED_METHOD:
        if (_listener != null)
          _listener(InterstitialAdResult.DISPLAYED, call.arguments);
        break;
      case DISMISSED_METHOD:
        if (_listener != null)
          _listener(InterstitialAdResult.DISMISSED, call.arguments);
        break;
      case ERROR_METHOD:
        if (_listener != null)
          _listener(InterstitialAdResult.ERROR, call.arguments);
        break;
      case LOADED_METHOD:
        if (_listener != null)
          _listener(InterstitialAdResult.LOADED, call.arguments);
        break;
      case CLICKED_METHOD:
        if (_listener != null)
          _listener(InterstitialAdResult.CLICKED, call.arguments);
        break;
      case LOGGING_IMPRESSION_METHOD:
        if (_listener != null)
          _listener(InterstitialAdResult.LOGGING_IMPRESSION, call.arguments);
        break;
    }
    return Future.value(true);
  }
}
