import Foundation
import Flutter
import FBAudienceNetwork


class FacebookAudienceNetworkNativeBannerAdFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar
    init(_registrar: FlutterPluginRegistrar) {
        print("NativeBannerAd > Factory register")
        
        registrar = _registrar
        super.init()
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        print("NativeBannerAd > Factory createArgsCodec")
        
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        print("NativeBannerAd > Factory create")
        
        return FacebookAudienceNetworkNativeBannerAdView(_frame: frame,
                                                        _viewId: viewId,
                                                        _params: args as? Dictionary<String, Any> ?? nil,
                                                        _registrar: registrar)
    }
}


class FacebookAudienceNetworkNativeBannerAdView: NSObject, FlutterPlatformView, FBNativeBannerAdDelegate {
    private let frame: CGRect
    private let viewId: Int64
    private let registrar: FlutterPluginRegistrar
    private let params: [String: Any]
    private let channel: FlutterMethodChannel
    
    var mainView: UIView!
    var nativeBannerAd: FBNativeBannerAd!
    var nativeAdViewAttributes: FBNativeAdViewAttributes!
    
    init(_frame: CGRect,
         _viewId: Int64,
         _params: [String: Any]?,
         _registrar: FlutterPluginRegistrar) {
        
        frame = _frame
        viewId = _viewId
        registrar = _registrar
        params = _params!
        channel = FlutterMethodChannel(
            name: "\(FANConstant.NATIVE_BANNER_AD_CHANNEL)_\(viewId)",
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
        print("NativeBannerAd > is deninit")
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
        print("NativeBannerAd > init initView")
        
        self.mainView = UIView(frame: self.frame)
        self.mainView.backgroundColor = UIColor.white
    }
    
    
    /**
     * init Ad
     **/
    func initFB() {
        print("NativeBannerAd > init initFB")
        
        initNativeAd()
        initNativeAdViewAttributes()
    }
    
    
    /**
     * load
     **/
    func initNativeAd() {
        print("NativeBannerAd > init initNativeAd")
        
        let existsId: Bool = (self.params["id"] != nil) ? true : false
        
        if (existsId) {
            let valueId: String = self.params["id"] as! String
            self.nativeBannerAd = FBNativeBannerAd(placementID: valueId)
            self.nativeBannerAd.delegate = self
            self.nativeBannerAd.loadAd()
        }
    }
    
    func initNativeAdViewAttributes() {
        print("NativeBannerAd > initNativeAdViewAttributes")

//        let buttonColor: String = self.params["button_color"] as! String
//        let buttonTitleColor: String = self.params["button_title_color"] as! String
//        let bgColor: String = self.params["bg_color"] as! String
//        let titleColor: String = self.params["title_color"] as! String
//        let descColor: String = self.params["desc_color"] as! String
//
//        let buttonColorUIColor = UIColor.init(hexString: buttonColor)
//        let buttonTitleColorUIColor = UIColor.init(hexString: buttonTitleColor)
//        let bgColorUIColor = UIColor.init(hexString: bgColor)
//        let titleColorUIColor = UIColor.init(hexString: titleColor)
//        let descColorUIColor = UIColor.init(hexString: descColor)
//
//        self.nativeAdViewAttributes = FBNativeAdViewAttributes()
//        self.nativeAdViewAttributes.buttonColor = buttonColorUIColor
//        self.nativeAdViewAttributes.buttonTitleColor = buttonTitleColorUIColor
//        self.nativeAdViewAttributes.backgroundColor = bgColorUIColor
//        self.nativeAdViewAttributes.titleColor = titleColorUIColor
//        self.nativeAdViewAttributes.descriptionColor = descColorUIColor
//
//        self.nativeAdViewAttributes.titleFont = UIFont(name: "Noteworthy", size: 15.0)
//        self.nativeAdViewAttributes.buttonTitleFont = UIFont(name: "Futura", size: 12.0)
    }
    
    /**
     * using native ad
     */
    func regTemplate() {
        print("NativeBannerAd > regNativeAdViewTemplate")
        
        let width: CGFloat = (self.params["width"] != nil) ? self.params["width"] as! CGFloat : UIScreen.main.bounds.size.width
        let height: CGFloat = (self.params["height"] != nil) ? self.params["height"] as! CGFloat : 100.0
        let viewType: FBNativeBannerAdViewType = getViewType(height)
        let nativeBannerAdView = FBNativeBannerAdView.init(nativeBannerAd: self.nativeBannerAd, with: viewType)
        nativeBannerAdView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        self.mainView.addSubview(nativeBannerAdView)
        self.mainView.layoutIfNeeded()
    }
    
    func getViewType(_ height:CGFloat) -> FBNativeBannerAdViewType {
        var result: FBNativeBannerAdViewType = FBNativeBannerAdViewType.genericHeight100
        
        if height == 50.0 {
            result = FBNativeBannerAdViewType.genericHeight50
        } else if height == 100.0 {
            result = FBNativeBannerAdViewType.genericHeight100
        } else if height == 120.0 {
            result = FBNativeBannerAdViewType.genericHeight120
        }
        return result
    }
    
    
    /**
     Sent when an FBNativeBannerAd has been successfully loaded.
     
     @param nativeBannerAd An FBNativeBannerAd object sending the message.
     */
    func nativeBannerAdDidLoad(_ nativeBannerAd: FBNativeBannerAd) {
        print("NativeBannerAdView > nativeBannerAdDidLoad")
        self.nativeBannerAd = nativeBannerAd
        regTemplate()
        
        let placement_id: String = nativeBannerAd.placementID
        let invalidated: Bool = nativeBannerAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOADED_METHOD, arguments: arg)
    }
    
    /**
     Sent when an FBNativeBannerAd has succesfully downloaded all media
     */
    func nativeBannerAdDidDownloadMedia(_ nativeBannerAd: FBNativeBannerAd) {
        print("NativeBannerAdView > nativeBannerAdDidDownloadMedia")
    }
    
    /**
     Sent immediately before the impression of an FBNativeBannerAd object will be logged.
     
     @param nativeBannerAd An FBNativeBannerAd object sending the message.
     */
    func nativeBannerAdWillLogImpression(_ nativeBannerAd: FBNativeBannerAd) {
        print("NativeBannerAdView > nativeBannerAdWillLogImpression")
        let placement_id: String = nativeBannerAd.placementID
        let invalidated: Bool = nativeBannerAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOGGING_IMPRESSION_METHOD, arguments: arg)
    }
    
    /**
     Sent when an FBNativeBannerAd is failed to load.
     
     @param nativeBannerAd An FBNativeBannerAd object sending the message.
     @param error An error object containing details of the error.
     */
    func nativeBannerAd(_ nativeBannerAd: FBNativeBannerAd, didFailWithError error: Error) {
        print("NativeBannerAdView > nativeBannerAd")
        let placement_id: String = nativeBannerAd.placementID
        let invalidated: Bool = nativeBannerAd.isAdValid
//        let errorStr: String = error as! String
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.ERROR_METHOD, arguments: arg)
    }
    
    /**
     Sent after an ad has been clicked by the person.
     
     @param nativeBannerAd An FBNativeBannerAd object sending the message.
     */
    func nativeBannerAdDidClick(_ nativeBannerAd: FBNativeBannerAd) {
        print("NativeBannerAdView > nativeBannerAdDidClick")
        let placement_id: String = nativeBannerAd.placementID
        let invalidated: Bool = nativeBannerAd.isAdValid
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
     
     @param nativeBannerAd An FBNativeBannerAd object sending the message.
     */
    func nativeBannerAdDidFinishHandlingClick(_ nativeBannerAd: FBNativeBannerAd) {
        print("NativeBannerAdView > nativeBannerAdDidFinishHandlingClick")
    }
}

