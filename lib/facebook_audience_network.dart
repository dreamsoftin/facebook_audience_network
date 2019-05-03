/// Facebook Audience Network plugin for Flutter applications.
///
/// This library uses native API of [Facebook Audience Network](https://developers.facebook.com/docs/audience-network)
/// to provide functionality for Flutter applications.
///
/// Currently only Android platform is supported.
library facebook_audience_network;

import 'package:flutter/services.dart';

import 'constants.dart';
import 'ad/ad_interstitial.dart';
import 'ad/ad_rewarded.dart';

export 'ad/ad_banner.dart';
export 'ad/ad_interstitial.dart';
export 'ad/ad_rewarded.dart';

/// All non-widget functions such as initialization, loading interstitial,
/// in-stream and reward video ads are enclosed in this class.
///
/// Initialize the Facebook Audience Network by calling the static [init]
/// function.
class FacebookAudienceNetwork {
  static const _channel = const MethodChannel(MAIN_CHANNEL);

  /// Initializes the Facebook Audience Network. [testingId] can be used to
  /// obtain test Ads.
  ///
  /// [testingId] can be obtained by running the app once without the testingId.
  /// Check the log to obtain the [testingId] for your device.
  static Future<bool> init({String testingId}) async {
    Map<String, String> initValues = {
      "testingId": testingId,
    };

    try {
      final result = await _channel.invokeMethod(INIT_METHOD, initValues);
      return result;
    } on PlatformException {
      return false;
    }
  }

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
  ///   'placement_id': "YOUR_PLACEMENT_ID",
  ///   'invalidated': false,
  ///   'error_code': 2,
  ///   'error_message': "No internet connection",
  /// }
  /// ```
  static Future<bool> loadInterstitialAd({
    String placementId = "YOUR_PLACEMENT_ID",
    Function(InterstitialAdResult, dynamic) listener,
  }) async {
    return await FacebookInterstitialAd.loadInterstitialAd(
      placementId: placementId,
      listener: listener,
    );
  }

  /// Shows an Interstitial Ad after it has been loaded. (This needs to be called
  /// only after calling [loadInterstitialAd] function). [delay] is in
  /// milliseconds.
  ///
  /// Example:
  ///
  /// ```dart
  /// FacebookAudienceNetwork.loadInterstitialAd(
  ///   listener: (result, value) {
  ///     if (result == InterstitialAdResult.LOADED)
  ///       FacebookAudienceNetwork.showInterstitialAd(delay: 5000);
  ///   },
  /// );
  /// ```
  static Future<bool> showInterstitialAd({int delay}) async {
    return await FacebookInterstitialAd.showInterstitialAd(delay: delay);
  }

  /// Removes the Ad.
  static Future<bool> destroyInterstitialAd() async {
    return await FacebookInterstitialAd.destroyInterstitialAd();
  }

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
    return await FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: placementId,
      listener: listener,
    );
  }

  /// Shows a rewarded video Ad after it has been loaded. (This needs to be
  /// called only after calling [loadRewardedVideoAd] function). [delay] is in
  /// milliseconds.
  ///
  /// Example:
  ///
  /// ```dart
  /// FacebookAudienceNetwork.loadRewardedVideoAd(
  ///   listener: (result, value) {
  ///     if(result == RewardedVideoResult.LOADED)
  ///       FacebookAudienceNetwork.showRewardedVideoAd();
  ///   },
  /// );
  /// ```
  static Future<bool> showRewardedVideoAd({int delay = 0}) async {
    return await FacebookRewardedVideoAd.showRewardedVideoAd(delay: delay);
  }

  /// Removes the rewarded video Ad.
  static Future<bool> destroyRewardedVideoAd() async {
    return await FacebookRewardedVideoAd.destroyRewardedVideoAd();
  }
}
