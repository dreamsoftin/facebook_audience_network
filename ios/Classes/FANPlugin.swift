import Flutter
import UIKit

public class FANPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        print(">> FAN Plugin register")

        registrar.register(
            FacebookAudienceNetworkBannerAdFactory(_registrar: registrar),
            withId: FANConstant.BANNER_AD_CHANNEL
        )

        registrar.register(
            FacebookAudienceNetworkNativeAdFactory(_registrar: registrar),
            withId: FANConstant.NATIVE_AD_CHANNEL
        )
        
        registrar.register(
            FacebookAudienceNetworkNativeBannerAdFactory(_registrar: registrar),
            withId: FANConstant.NATIVE_BANNER_AD_CHANNEL
        )
        
        //init
        let FANPluginChannel: FlutterMethodChannel = FlutterMethodChannel.init(name: FANConstant.MAIN_CHANNEL, binaryMessenger: registrar.messenger())
        
        FANPluginFactory.init(_channel: FANPluginChannel)
        
        let interstitialAdChannel: FlutterMethodChannel = FlutterMethodChannel.init(name: FANConstant.INTERSTITIAL_AD_CHANNEL, binaryMessenger: registrar.messenger())
        
        FacebookAudienceNetworkInterstitialAdPlugin.init(_channel: interstitialAdChannel)
    }
}
