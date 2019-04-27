library facebook_audience_network;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FacebookAudienceNetwork {

  static const _battery = const MethodChannel("fb.audience.network.io");

  static Future<int> getBatteryLevel() async {
    try {
      final int result = await _battery.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      throw "Failed to get battery level: '${e.message}'.";
    }
  }
}
