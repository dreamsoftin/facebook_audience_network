library facebook_audience_network;

import 'package:flutter/services.dart';

export 'ad/ad_banner.dart';
export 'ad/ad_native.dart';

class FacebookAudienceNetwork {
  static const _channel = const MethodChannel("fb.audience.network.io");

  static Future<bool> init({
    String placementId = "YOUR_PLACEMENT_ID",
    String testingId = "",
  }) async {
    Map<String, String> initValues = {
      "placementId": placementId,
      "testingId": testingId,
    };

    try {
      final result = await _channel.invokeMethod("init", initValues);
      return result;
    } on PlatformException {
      return false;
    }
  }
}
