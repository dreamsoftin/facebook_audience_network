import Foundation
import Flutter
import FBAudienceNetwork


class FacebookAudienceNetworkBannerAdFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar
    init(_registrar: FlutterPluginRegistrar) {
        print("FAN > BannerAdFactory > Factory register")
        
        registrar = _registrar
        super.init()
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        print("FAN > BannerAdFactory > Factory createArgsCodec")
        
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        print("FAN >  BannerAdFactory > Factory create")
        
        return FacebookAudienceNetworkBannerAdView(_frame: frame,
                                                        _viewId: viewId,
                                                        _params: args as? Dictionary<String, Any> ?? nil,
                                                        _registrar: registrar)
    }
}


class FacebookAudienceNetworkBannerAdView: NSObject, FlutterPlatformView, FBAdViewDelegate {
    private let frame: CGRect
    private let viewId: Int64
    private let registrar: FlutterPluginRegistrar
    private let params: [String: Any]
    private let channel: FlutterMethodChannel
    
    var mainView: UIView!
    var bannerAd: FBAdView!
    
    
    init(_frame: CGRect,
         _viewId: Int64,
         _params: [String: Any]?,
         _registrar: FlutterPluginRegistrar) {
        
        frame = _frame
        viewId = _viewId
        registrar = _registrar
        params = _params!
        channel = FlutterMethodChannel(
            name: "\(FANConstant.BANNER_AD_CHANNEL)_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        
        super.init()
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let `self` = self else { return }
            `self`.handle(call, result: result)
        }
        
        initView()
        initFB()
    }
    
    deinit {
        print("FAN > BannerAdView > is deninit")
    }
    
    func view() -> UIView {
        return mainView
    }
    
    
    /**
     * handle
     */
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialization":
            result(true)
        case "init":
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    /**
     * initView
     **/
    func initView() {
        print("BannerAdView > init initView")
        
        self.mainView = UIView(frame: self.frame)
        self.mainView.backgroundColor = UIColor.white
    }
    
    
    /**
     * init Ad
     **/
    func initFB() {
        print("FAN > BannerAdView > init initFB")
        
        let existsBannerId: Bool = (self.params["banner_ad"] != nil) ? true : false
        let valueBannerAd: Bool = (existsBannerId) ? self.params["banner_ad"] as! Bool : false
        
        if (existsBannerId && valueBannerAd) {
            // init banner
        } else {
            // init native
            initBannerAd()
//            initBannerAdViewAttributes()
        }
    }
    
    
    /**
     * load
     **/
    func initBannerAd() {
        print("FAN > BannerAdView > init initBannerAd")
        
        let existsId: Bool = (self.params["id"] != nil)
            ? true : false
        let valueId: String = existsId
            ? self.params["id"] as! String : ""
        let height: CGFloat = (self.params["height"] != nil)
            ? self.params["height"] as! CGFloat : 50.0
		var adSize = kFBAdSizeHeight50Banner
		if (height >= 250.0)
		{
			adSize = kFBAdSizeHeight250Rectangle
		}
		else if (height >= 90.0)
		{
			adSize = kFBAdSizeHeight90Banner
		}
		
        //let adSize: FBAdSize = FBAdSize.init(size: CGSize.init(width: width, height: height))
        
        if (existsId) {
            self.bannerAd = FBAdView.init(placementID: valueId, adSize: adSize, rootViewController: UIApplication.shared.keyWindow?.rootViewController)
            self.bannerAd.delegate = self
            self.bannerAd.loadAd()
        }
    }
    
    
    /**
     * using native ad
     */
    func regBannerAdViewTemplate() {
        print("FAN > BannerAdView > regNativeAdViewTemplate")
        
        self.mainView.addSubview(self.bannerAd)
        self.mainView.layoutIfNeeded()
    }
    
    
    /**
     Sent after an ad has been clicked by the person.
     
     @param adView An FBAdView object sending the message.
     */
    func adViewDidClick(_ adView :FBAdView) {
        print("FAN > BannerAdView > adViewDidClick")
        let placement_id: String = adView.placementID
        let invalidated: Bool = adView.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.CLICKED_METHOD, arguments: arg)
    }
    /**
     When an ad is clicked, the modal view will be presented. And when the user finishes the
     interaction with the modal view and dismiss it, this message will be sent, returning control
     to the application.
     
     @param adView An FBAdView object sending the message.
     */
    func adViewDidFinishHandlingClick(_ adView :FBAdView) {
        print("FAN > BannerAdView > adViewDidFinishHandlingClick")
    }
    /**
     Sent when an ad has been successfully loaded.
     
     @param adView An FBAdView object sending the message.
     */
    func adViewDidLoad(_ adView :FBAdView) {
        print("FAN > BannerAdView > adViewDidLoad")
        self.bannerAd = adView
        regBannerAdViewTemplate()
        
        let placement_id: String = adView.placementID
        let invalidated: Bool = adView.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOADED_METHOD, arguments: arg)
    }
    /**
     Sent after an FBAdView fails to load the ad.
     
     @param adView An FBAdView object sending the message.
     @param error An error object containing details of the error.
     */
    func  adView(_ adView :FBAdView, didFailWithError error: Error) {
        print("BannerAdView > adView")
        let placement_id: String = adView.placementID
        let invalidated: Bool = adView.isAdValid
        let errorStr: String = error.localizedDescription
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
            FANConstant.ERROR_ARG:errorStr
        ]
        self.channel.invokeMethod(FANConstant.ERROR_METHOD, arguments: arg)
    }
    
    /**
     Sent immediately before the impression of an FBAdView object will be logged.
     
     @param adView An FBAdView object sending the message.
     */
    func adViewWillLogImpression(_ adView :FBAdView) {
        print("BannerAdView > adViewWillLogImpression")
        let placement_id: String = adView.placementID
        let invalidated: Bool = adView.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOGGING_IMPRESSION_METHOD, arguments: arg)
    }
}



