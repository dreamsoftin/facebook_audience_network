import Flutter
import UIKit

public class FANPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        print(">> FAN Plugin register")
        
        registrar.register(
            FacebookAudienceNetworkBannerAdFactory(_registrar: registrar),
            withId: FbConstant.BANNER_AD_CHANNEL
        )

        registrar.register(
            FacebookAudienceNetworkNativeAdFactory(_registrar: registrar),
            withId: FbConstant.NATIVE_AD_CHANNEL
        )
        
        registrar.register(
            FacebookAudienceNetworkNativeBannerAdFactory(_registrar: registrar),
            withId: FbConstant.NATIVE_BANNER_AD_CHANNEL
        )
        
        let interstitialAdChannel: FlutterMethodChannel = FlutterMethodChannel.init(name: FbConstant.INTERSTITIAL_AD_CHANNEL, binaryMessenger: registrar.messenger())
        
        FacebookAudienceNetworkInterstitialAdPlugin.init(_channel: interstitialAdChannel)
    }
}
