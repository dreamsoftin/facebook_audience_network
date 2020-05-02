import Foundation
import Flutter
import FBAudienceNetwork

class FacebookAudienceNetworkInterstitialAdPlugin: NSObject, FBInterstitialAdDelegate {
    let channel: FlutterMethodChannel
    var interstitialAd: FBInterstitialAd!
    
    init(_channel: FlutterMethodChannel) {
        print("FacebookAudienceNetworkInterstitialAdPlugin > init")
        
        channel = _channel
        
        super.init()
        
        channel.setMethodCallHandler { (call, result) in
            switch call.method{
            case "loadInterstitialAd":
                print("FacebookAudienceNetworkInterstitialAdPlugin > loadInterstitialAd")
                result(self.loadAd(call))
            case "showInterstitialAd":
                print("FacebookAudienceNetworkInterstitialAdPlugin > showInterstitialAd")
                result(self.showAD(call))
            case "destroyInterstitialAd":
                print("FacebookAudienceNetworkInterstitialAdPlugin > destroyInterstitialAd")
                result(self.destroyAd())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        print("FacebookAudienceNetworkInterstitialAdPlugin > init > end")
    }
    
    
    func loadAd(_ call: FlutterMethodCall) -> Bool {
        if nil == self.interstitialAd || !self.interstitialAd.isAdValid {
            print("FacebookAudienceNetworkInterstitialAdPlugin > loadAd > create")
            let args: NSDictionary = call.arguments as! NSDictionary
            let id: String = args["id"] as! String
            self.interstitialAd = FBInterstitialAd.init(placementID: id)
            self.interstitialAd.delegate = self
        }
        self.interstitialAd.load()
        return true
    }
    
    func showAD(_ call: FlutterMethodCall) -> Bool {
        if !self.interstitialAd.isAdValid {
            print("FacebookAudienceNetworkInterstitialAdPlugin > showAD > not AdVaild")
            return false
        }
        let args: NSDictionary = call.arguments as! NSDictionary
        let delay: Int = args["delay"] as! Int
        
        self.interstitialAd.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
        
        print("@@@ delay %d", delay)
        
        if 0 < delay {
            let time = DispatchTime.now() + .seconds(delay)
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.interstitialAd.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
            }
        } else {
            self.interstitialAd.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
        }
        return true
    }
    
    func destroyAd() -> Bool {
        if nil == self.interstitialAd {
            return false
        } else {
            interstitialAd.delegate = nil
            interstitialAd = nil
        }
        return true
    }
    
    
    /**
     Sent after an ad in the FBInterstitialAd object is clicked. The appropriate app store view or
     app browser will be launched.
     
     @param interstitialAd An FBInterstitialAd object sending the message.
     */
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        print("InterstitialAdView > interstitialAdDidClick")
        
        let placement_id: String = interstitialAd.placementID
        let invalidated: Bool = interstitialAd.isAdValid
        let arg: [String: Any] = [
            FbConstant.PLACEMENT_ID_ARG: placement_id,
            FbConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FbConstant.CLICKED_METHOD, arguments: arg)
    }
    
    /**
     Sent after an FBInterstitialAd object has been dismissed from the screen, returning control
     to your application.
     
     @param interstitialAd An FBInterstitialAd object sending the message.
     */
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        print("InterstitialAdView > interstitialAdDidClose")
    }
    
    /**
     Sent immediately before an FBInterstitialAd object will be dismissed from the screen.
     
     @param interstitialAd An FBInterstitialAd object sending the message.
     */
    func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
        print("InterstitialAdView > interstitialAdWillClose")
    }
    
    /**
     Sent when an FBInterstitialAd successfully loads an ad.
     
     @param interstitialAd An FBInterstitialAd object sending the message.
     */
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        print("InterstitialAdView > interstitialAdDidLoad")
        
        let placement_id: String = interstitialAd.placementID
        let invalidated: Bool = interstitialAd.isAdValid
        let arg: [String: Any] = [
            FbConstant.PLACEMENT_ID_ARG: placement_id,
            FbConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FbConstant.LOADED_METHOD, arguments: arg)
    }
    
    /**
     Sent when an FBInterstitialAd failes to load an ad.
     
     @param interstitialAd An FBInterstitialAd object sending the message.
     @param error An error object containing details of the error.
     */
    func interstitialAd(_ interstitialAd :FBInterstitialAd, didFailWithError error: Error) {
        print("InterstitialAdView > interstitialAd")
        
        let placement_id: String = interstitialAd.placementID
        let invalidated: Bool = interstitialAd.isAdValid
        let arg: [String: Any] = [
            FbConstant.PLACEMENT_ID_ARG: placement_id,
            FbConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FbConstant.ERROR_METHOD, arguments: arg)
    }
    
    /**
     Sent immediately before the impression of an FBInterstitialAd object will be logged.
     
     @param interstitialAd An FBInterstitialAd object sending the message.
     */
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        print("InterstitialAdView > interstitialAdWillLogImpression")
        
        let placement_id: String = interstitialAd.placementID
        let invalidated: Bool = interstitialAd.isAdValid
        let arg: [String: Any] = [
            FbConstant.PLACEMENT_ID_ARG: placement_id,
            FbConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FbConstant.LOGGING_IMPRESSION_METHOD, arguments: arg)
    }
}
