import Foundation
import Flutter
import FBAudienceNetwork


class FacebookAudienceNetworkNativeAdFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar
    init(_registrar: FlutterPluginRegistrar) {
        print("NativeAd > Factory register")
        
        registrar = _registrar
        super.init()
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        print("NativeAd > Factory createArgsCodec")
        
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        print("NativeAd > Factory create")
        
        return FacebookAudienceNetworkNativeAdView(_frame: frame,
                                                _viewId: viewId,
                                                _params: args as? Dictionary<String, Any> ?? nil,
                                                _registrar: registrar)
    }
}


class FacebookAudienceNetworkNativeAdLayout {
    var adView: CGRect!
    var adIconRect: CGRect!
    var adTitleLabelRect: CGRect!
    var adSponsoredRect: CGRect!
    var adOptionsRect: CGRect!
    var adMediaRect: CGRect!
    var adCoverRect: CGRect!
    var adCallToActionRect: CGRect!
    var adBodyLabelRect: CGRect!
}


class FacebookAudienceNetworkNativeAdView: NSObject, FlutterPlatformView, FBNativeAdDelegate {
    private let frame: CGRect
    private let viewId: Int64
    private let registrar: FlutterPluginRegistrar
    private let params: [String: Any]
    private let channel: FlutterMethodChannel

    var mainView: UIView!
    var nativeAd: FBNativeAd!
    // native
    var nativeAdViewAttributes: FBNativeAdViewAttributes!
    var nativeAdLayout: FacebookAudienceNetworkNativeAdLayout!
    // custom
    var adView: UIView!
    var adIconView: FBAdIconView!
    var adMediaView: FBMediaView!
    var adCoverView: UIView!
    var adTitleLabel: UILabel!
    var adBodyLabel: UILabel!
    var adCallToActionButton: UIButton!
    var adSocialContextLabel: UILabel!
    var adSponsoredLabel: UILabel!
    var adOptionsView: FBAdOptionsView!
    //
    var sponsoredColor: UIColor!
    var sponsoredFont: UIFont!
    var descriptionLabelLines: NSInteger!

    init(_frame: CGRect,
         _viewId: Int64,
         _params: [String: Any]?,
         _registrar: FlutterPluginRegistrar) {

        frame = _frame
        viewId = _viewId
        registrar = _registrar
        params = _params!
        channel = FlutterMethodChannel(
            name: "\(FANConstant.NATIVE_AD_CHANNEL)_\(viewId)",
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
        print("NativeAd > is deninit")
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
        print("NativeAd > init initView")

        self.mainView = UIView(frame: self.frame)
        self.mainView.backgroundColor = UIColor.clear
    }


    /**
     * init Ad
     **/
    func initFB() {
        print("NativeAd > init initFB")

        initNativeAd()
    }


    /**
     * load
     **/
    func initNativeAd() {
        print("NativeAd > init initNativeAd")

        let existsId: Bool = (self.params["id"] != nil) ? true : false

        if (existsId) {
            let valueId: String = self.params["id"] as? String ?? "";
            self.nativeAd = FBNativeAd(placementID: valueId)
            self.nativeAd.delegate = self
            self.nativeAd.loadAd()
        }
    }


    /**
     * using native ad
     */
    func regNativeAdView() {
        var adType: Int = self.params["ad_type"] as? Int ?? FANConstant.NATIVE_AD_TEMPLATE;

        switch adType {
        case FANConstant.NATIVE_AD_HORIZONTAL:
            initNativeAdViewAttributes()
            initNativeAdViewAttributesCustomHorizontal()
            regNativeAdViewCustomHorizontal()
            break;
        case FANConstant.NATIVE_AD_VERTICAL:
            initNativeAdViewAttributes()
            initNativeAdViewAttributesCustomVertical()
            regNativeAdViewCustomVertical()
            break;
        default:
            initNativeAdViewAttributes()
            regNativeAdViewTemplate()
            break;
        }
    }


    func initNativeAdViewAttributes() {
        print("NativeAd > initNativeAdViewAttributes")

        let buttonColor: String = self.params["button_color"] as? String ?? "0xFFF8D000";
        let buttonBorderColor: String = self.params["button_border_color"] as? String ?? "0xFFF8D000";
        let buttonTitleColor: String = self.params["button_title_color"] as? String ?? "0xFF001E31";
        let bgColor: String = self.params["bg_color"] as? String ?? "0xFFFFFFFF";
        let titleColor: String = self.params["title_color"] as? String ?? "0xFF001E31";
        let descColor: String = self.params["desc_color"] as? String ?? "0xFF001E31";

        let buttonColorUIColor = UIColor.init(hexString: buttonColor)
        let buttonBorderColorUIColor = UIColor.init(hexString: buttonBorderColor)
        let buttonTitleColorUIColor = UIColor.init(hexString: buttonTitleColor)
        let bgColorUIColor = UIColor.init(hexString: bgColor)
        let titleColorUIColor = UIColor.init(hexString: titleColor)
        let descColorUIColor = UIColor.init(hexString: descColor)

        self.nativeAdViewAttributes = FBNativeAdViewAttributes()
        self.nativeAdViewAttributes.buttonColor = buttonColorUIColor
        self.nativeAdViewAttributes.buttonBorderColor = buttonBorderColorUIColor
        self.nativeAdViewAttributes.buttonTitleColor = buttonTitleColorUIColor
        self.nativeAdViewAttributes.backgroundColor = bgColorUIColor
        self.nativeAdViewAttributes.titleColor = titleColorUIColor
        self.nativeAdViewAttributes.descriptionColor = descColorUIColor
        self.sponsoredColor = UIColor.init(hexString: "0xFFA1ACC0")

        self.nativeAdViewAttributes.titleFont = UIFont.systemFont(ofSize: 12)
        self.nativeAdViewAttributes.descriptionFont = UIFont.systemFont(ofSize: 14)
        self.nativeAdViewAttributes.buttonTitleFont = UIFont.systemFont(ofSize: 13)
        self.sponsoredFont = UIFont.systemFont(ofSize: 10)

        self.descriptionLabelLines = 2
    }


    /*
     * Register Native Ad
     */
    func regNativeAdViewTemplate() {
        print("NativeAd > regNativeAdViewTemplate")

//        let isRegistered: Bool = self.nativeAd.isRegistered
//        if (isRegistered) {
//            print("NativeAd > regNativeAdViewTemplate > isRegistered")
//            self.mainView.layoutIfNeeded()
//            return
//        }

        let width: CGFloat = (nil != self.mainView) ? self.mainView.bounds.width : 0.0;
        let height: CGFloat = (nil != self.mainView) ? self.mainView.bounds.height : 0.0;
        let nativeAdView = FBNativeAdView.init(nativeAd: self.nativeAd, with: FBNativeAdViewType.dynamic, with: self.nativeAdViewAttributes)
        nativeAdView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        self.mainView.addSubview(nativeAdView)
        self.mainView.layoutIfNeeded()
    }


    func initNativeAdViewAttributesCustomHorizontal() {
        print("NativeAd > initNativeAdViewAttributesCustomHorizontal")

        let width: CGFloat = (nil != self.mainView) ? self.mainView.bounds.width : 0.0;
        let height: CGFloat = (nil != self.mainView) ? self.mainView.bounds.height : 0.0;
        let isMediaCover: Bool = self.params["is_media_cover"] as? Bool ?? false;

        self.nativeAdLayout = FacebookAudienceNetworkNativeAdLayout()

        // padding
        let padding: CGFloat = 0.0;
        let adIconPaddingX: CGFloat = 5.0
        let adIconPaddingY: CGFloat = 10.0
        let adTitleLabelPaddingX: CGFloat = 5.0
        let adTitleLabelPaddingY: CGFloat = 10.0
        let adSponsoredPaddingX: CGFloat = 5.0
        let adBodyLabelPaddingX: CGFloat = 5.0
        let adMediaPaddingY: CGFloat = 10.0

        // width/height
        let viewWidth: CGFloat = width - (padding * 2)
        let viewHeight: CGFloat = height - (padding * 2)
        let adIconWidth: CGFloat = 30.0
        let adIconHeight: CGFloat = 30.0
        let adCallToActionWidth: CGFloat = 100.0
        let adCallToActionHeight: CGFloat = 30.0
        let adTitleLabelWidth: CGFloat = viewWidth - adIconWidth - adIconPaddingX - adCallToActionWidth - adTitleLabelPaddingX
        let adTitleLabelHeight: CGFloat = 15.0
        let adSponsoredWidth: CGFloat = 70.0
        let adSponsoredHeight: CGFloat = 15.0
        let adOptionsWidth: CGFloat = 40.0
        let adOptionsHeight: CGFloat = 15.0
        let adBodyLabelWidth: CGFloat = viewWidth - (adBodyLabelPaddingX * 2.0)
        let adBodyLabelHeight: CGFloat = 70.0
        let adMediaWidth: CGFloat = width
        let adMediaHeight: CGFloat = viewHeight - adIconPaddingY - adIconHeight - adMediaPaddingY - adBodyLabelHeight
        let adCoverWidth: CGFloat = isMediaCover ? adMediaWidth - 16.0 : 0.0
        let adCoverHeight: CGFloat = isMediaCover ? adMediaHeight : 0.0

        let adIconX: CGFloat = adIconPaddingX
        let adIconY: CGFloat = adIconPaddingY
        let adCallToActionX: CGFloat = viewWidth - adCallToActionWidth;
        let adCallToActionY: CGFloat = adIconPaddingY
        let adTitleLabelX: CGFloat = adIconX + adIconWidth + adIconPaddingX + adTitleLabelPaddingX
        let adTitleLabelY: CGFloat = adTitleLabelPaddingY
        let adSponsoredX: CGFloat = adIconX + adIconWidth + adIconPaddingX + adSponsoredPaddingX
        let adSponsoredY: CGFloat = adTitleLabelY + adTitleLabelHeight
        let adOptionsX: CGFloat = adSponsoredX + adSponsoredWidth
        let adOptionsY: CGFloat = adTitleLabelY + adTitleLabelHeight
        let adMediaX: CGFloat = -padding
        let adMediaY: CGFloat = adIconY + adIconHeight + adMediaPaddingY
        let adCoverX: CGFloat = isMediaCover ? adMediaX + 16.0 : 0
        let adCoverY: CGFloat = isMediaCover ? adMediaY : 0
        let adBodyLabelX: CGFloat = adBodyLabelPaddingX
        let adBodyLabelY: CGFloat = viewHeight - adBodyLabelHeight

        nativeAdLayout.adView = CGRect(x: padding, y: padding, width: viewWidth, height: viewHeight)
        nativeAdLayout.adIconRect = CGRect(x: adIconX, y: adIconY, width: adIconWidth, height: adIconHeight)
        nativeAdLayout.adTitleLabelRect = CGRect(x: adTitleLabelX, y: adTitleLabelY, width: adTitleLabelWidth, height: adTitleLabelHeight)
        nativeAdLayout.adSponsoredRect = CGRect(x: adSponsoredX, y: adSponsoredY, width: adSponsoredWidth, height: adSponsoredHeight)
        nativeAdLayout.adOptionsRect = CGRect(x: adOptionsX, y: adOptionsY, width: adOptionsWidth, height: adOptionsHeight)
        nativeAdLayout.adMediaRect = CGRect(x: adMediaX, y: adMediaY, width: adMediaWidth, height: adMediaHeight)
        nativeAdLayout.adCoverRect = CGRect(x: adCoverX, y: adCoverY, width: adCoverWidth, height: adCoverHeight)
        nativeAdLayout.adCallToActionRect = CGRect(x: adCallToActionX, y: adCallToActionY, width: adCallToActionWidth, height: adCallToActionHeight)
        nativeAdLayout.adBodyLabelRect = CGRect(x: adBodyLabelX, y: adBodyLabelY, width: adBodyLabelWidth, height: adBodyLabelHeight)
    }


    func regNativeAdViewCustomHorizontal() {
        print("NativeAd > regNativeAdViewCustomHorizontal")
//        let isRegistered: Bool = self.nativeAd.isRegistered
//        if (isRegistered) {
//            print("NativeAd > regNativeAdViewCustomHorizontal > isRegistered")
//            self.mainView.layoutIfNeeded()
//            return
//        }

        // AdView
        self.adView = UIView.init(frame: nativeAdLayout.adView );
        self.adView.backgroundColor = self.nativeAdViewAttributes.backgroundColor

        // Icon
        self.adIconView = FBAdIconView.init(frame: nativeAdLayout.adIconRect)
        self.adIconView.layer.cornerRadius = nativeAdLayout.adIconRect.width / 2
        self.adView.addSubview(self.adIconView)

        // Options
        self.adOptionsView = FBAdOptionsView.init(frame: nativeAdLayout.adOptionsRect)
        self.adOptionsView.backgroundColor = self.nativeAdViewAttributes.backgroundColor
        self.adOptionsView.tintColor = UIColor.init(hexString: "0xFFA1ACC0")
        self.adView.addSubview(self.adOptionsView)

        // Title
        self.adTitleLabel = UILabel.init(frame: nativeAdLayout.adTitleLabelRect)
        self.adTitleLabel.text = self.nativeAd.advertiserName ?? ""
        self.adTitleLabel.textColor = self.nativeAdViewAttributes.titleColor
        self.adTitleLabel.font = self.nativeAdViewAttributes.titleFont
        self.adView.addSubview(self.adTitleLabel)

        // Sponsored
        self.adSponsoredLabel = UILabel.init(frame: nativeAdLayout.adSponsoredRect)
        self.adSponsoredLabel.text = self.nativeAd.sponsoredTranslation ?? ""
        self.adSponsoredLabel.textColor = sponsoredColor
        self.adSponsoredLabel.font = sponsoredFont
        self.adView.addSubview(self.adSponsoredLabel)

        // Media
        self.adMediaView = FBMediaView.init(frame: nativeAdLayout.adMediaRect)
        self.adView.addSubview(self.adMediaView)

        // Cover
        self.adCoverView = UIView.init(frame: nativeAdLayout.adCoverRect);
        self.adView.addSubview(self.adCoverView)

        // Button
        self.adCallToActionButton = UIButton.init(frame: nativeAdLayout.adCallToActionRect)
        self.adCallToActionButton.backgroundColor = self.nativeAdViewAttributes.buttonColor
        self.adCallToActionButton.setTitle(self.nativeAd.callToAction ?? "", for: .normal)
        self.adCallToActionButton.setTitleColor(self.nativeAdViewAttributes.buttonTitleColor, for: .normal)
        self.adCallToActionButton.titleLabel?.font = self.nativeAdViewAttributes.buttonTitleFont
        self.adCallToActionButton.titleLabel?.textAlignment = .left
        self.adCallToActionButton.layer.cornerRadius = 3.0
        self.adView.addSubview(self.adCallToActionButton)

        // BodyLabel
        self.adBodyLabel = UILabel.init(frame: nativeAdLayout.adBodyLabelRect)
        self.adBodyLabel.text = self.nativeAd.bodyText ?? ""
        self.adBodyLabel.textColor = self.nativeAdViewAttributes.descriptionColor
        self.adBodyLabel.font = self.nativeAdViewAttributes.descriptionFont
        self.adBodyLabel.numberOfLines = descriptionLabelLines
        self.adView.addSubview(self.adBodyLabel)

        //
        self.nativeAd.unregisterView()
        self.nativeAd.registerView(
            forInteraction: self.adView,
            mediaView: self.adMediaView,
            iconView: self.adIconView,
            viewController: UIApplication.shared.keyWindow?.rootViewController,
            clickableViews: [self.adCallToActionButton, self.adMediaView]

        )

        //
        self.adOptionsView.nativeAd = self.nativeAd

        // MainView
        self.mainView.addSubview(adView)
        self.mainView.layoutIfNeeded()
    }


    func initNativeAdViewAttributesCustomVertical() {
        print("NativeAd > initNativeAdViewAttributesCustomVertical")

        let width: CGFloat = (nil != self.mainView) ? self.mainView.bounds.width : 0.0;
        let height: CGFloat = (nil != self.mainView) ? self.mainView.bounds.height : 0.0;
        let isMediaCover: Bool = self.params["is_media_cover"] as? Bool ?? false;

        self.nativeAdLayout = FacebookAudienceNetworkNativeAdLayout()

        // padding
        let padding: CGFloat = 0.0;
        let bottomPadding: CGFloat = 10.0;
        let adMediaPaddingY: CGFloat = 0.0
        let adIconPaddingX: CGFloat = 0.0
        let adIconPaddingY: CGFloat = 0.0
        let adTitleLabelPaddingX: CGFloat = 5.0
        let adTitleLabelPaddingY: CGFloat = 4.0
        let adSponsoredPaddingX: CGFloat = 5.0
        let adSponsoredPaddingY: CGFloat = 0.0
        let adOptionsPaddingY: CGFloat = 0.0
        let adBodyLabelPaddingX: CGFloat = 5.0
        let adBodyLabelPaddingY: CGFloat = 5.0
        let adCallToActionPaddingX: CGFloat = 10.0
        let adCallToActionPaddingY: CGFloat = 5.0

        // width/height
        let viewWidth: CGFloat = width
        let viewHeight: CGFloat = height - bottomPadding
        let adIconWidth: CGFloat = 0.0
        let adIconHeight: CGFloat = 0.0
        let adOptionsWidth: CGFloat = 40.0
        let adOptionsHeight: CGFloat = 20.0
        let adTitleLabelWidth: CGFloat = viewWidth - adOptionsWidth - adTitleLabelPaddingX
        let adTitleLabelHeight: CGFloat = 20.0
        let adSponsoredWidth: CGFloat = viewWidth - adOptionsWidth - adSponsoredPaddingX
        let adSponsoredHeight: CGFloat = 20.0
        let adBodyLabelWidth: CGFloat = viewWidth - (adBodyLabelPaddingX * 2.0)
        let adBodyLabelHeight: CGFloat = 70.0
        let adCallToActionWidth: CGFloat = viewWidth - (adCallToActionPaddingX * 2.0)
        let adCallToActionHeight: CGFloat = 36.0
        let adMediaWidth: CGFloat = viewWidth
        let adMediaHeight: CGFloat = viewHeight - adMediaPaddingY - adTitleLabelPaddingY - adTitleLabelHeight - adSponsoredPaddingY - adSponsoredHeight - adBodyLabelPaddingY - adBodyLabelHeight - adCallToActionPaddingY - adCallToActionHeight
        let adCoverWidth: CGFloat = isMediaCover ? adMediaWidth - 16.0 : 0.0
        let adCoverHeight: CGFloat = isMediaCover ? adMediaHeight : 0.0

        let adMediaX: CGFloat = 0.0
        let adMediaY: CGFloat = 0.0
        let adCoverX: CGFloat = isMediaCover ? adMediaX + 16.0 : 0.0
        let adCoverY: CGFloat = isMediaCover ? adMediaY : 0.0
        let adIconX: CGFloat = adIconPaddingX
        let adIconY: CGFloat = adIconPaddingY
        let adTitleLabelX: CGFloat = adTitleLabelPaddingX
        let adTitleLabelY: CGFloat = adMediaX + adMediaHeight + adTitleLabelPaddingY
        let adSponsoredX: CGFloat = adSponsoredPaddingX
        let adSponsoredY: CGFloat = adTitleLabelY + adTitleLabelHeight + adSponsoredPaddingY
        let adOptionsX: CGFloat = viewWidth - adOptionsWidth
        let adOptionsY: CGFloat = adMediaX + adMediaHeight + adOptionsPaddingY
        let adBodyLabelX: CGFloat = adBodyLabelPaddingX
        let adBodyLabelY: CGFloat = adSponsoredY + adSponsoredHeight + adBodyLabelPaddingY
        let adCallToActionX: CGFloat = adCallToActionPaddingX;
        let adCallToActionY: CGFloat = adBodyLabelY + adBodyLabelHeight + adCallToActionPaddingY

        nativeAdLayout.adView = CGRect(x: padding, y: padding, width: viewWidth, height: viewHeight)
        nativeAdLayout.adMediaRect = CGRect(x: adMediaX, y: adMediaY, width: adMediaWidth, height: adMediaHeight)
        nativeAdLayout.adCoverRect = CGRect(x: adCoverX, y: adCoverY, width: adCoverWidth, height: adCoverHeight)
        nativeAdLayout.adOptionsRect = CGRect(x:adOptionsX, y: adOptionsY, width: adOptionsWidth, height: adOptionsHeight)
        nativeAdLayout.adIconRect = CGRect(x: adIconX, y: adIconY, width: adIconWidth, height: adIconHeight)
        nativeAdLayout.adTitleLabelRect = CGRect(x: adTitleLabelX, y: adTitleLabelY, width: adTitleLabelWidth, height: adTitleLabelHeight)
        nativeAdLayout.adSponsoredRect = CGRect(x: adSponsoredX, y: adSponsoredY, width: adSponsoredWidth, height: adSponsoredHeight)
        nativeAdLayout.adBodyLabelRect = CGRect(x: adBodyLabelX, y: adBodyLabelY, width: adBodyLabelWidth, height: adBodyLabelHeight)
        nativeAdLayout.adCallToActionRect = CGRect(x: adCallToActionX, y: adCallToActionY, width: adCallToActionWidth, height: adCallToActionHeight)
    }


    func regNativeAdViewCustomVertical() {
        print("NativeAd > regNativeAdViewCustomVertical")
//        let isRegistered: Bool = self.nativeAd.isRegistered
//        if (isRegistered) {
//            print("NativeAd > regNativeAdViewCustomHorizontal > isRegistered")
//            self.mainView.layoutIfNeeded()
//            return
//        }

        // AdView
        self.adView = UIView.init(frame: nativeAdLayout.adView );
        self.adView.backgroundColor = self.nativeAdViewAttributes.backgroundColor

        // Media
        self.adMediaView = FBMediaView.init(frame: nativeAdLayout.adMediaRect)
        self.adView.addSubview(self.adMediaView)

        // Cover
        self.adCoverView = UIView.init(frame: nativeAdLayout.adCoverRect);
        self.adView.addSubview(self.adCoverView)

        // Choice
        self.adOptionsView = FBAdOptionsView.init(frame: nativeAdLayout.adOptionsRect)
        self.adOptionsView.backgroundColor = self.nativeAdViewAttributes.backgroundColor
        self.adView.addSubview(self.adOptionsView)

        // Icon
        self.adIconView = FBAdIconView.init(frame: nativeAdLayout.adIconRect)
        self.adIconView.layer.cornerRadius = nativeAdLayout.adIconRect.width / 2
        self.adView.addSubview(self.adIconView)

        // Title
        self.adTitleLabel = UILabel.init(frame: nativeAdLayout.adTitleLabelRect)
        self.adTitleLabel.text = self.nativeAd.advertiserName ?? ""
        self.adTitleLabel.textColor = self.nativeAdViewAttributes.titleColor
        self.adTitleLabel.font = self.nativeAdViewAttributes.titleFont
        self.adView.addSubview(self.adTitleLabel)

        // Sponsored
        self.adSponsoredLabel = UILabel.init(frame: nativeAdLayout.adSponsoredRect)
        self.adSponsoredLabel.text = self.nativeAd.sponsoredTranslation ?? ""
        self.adSponsoredLabel.textColor = sponsoredColor
        self.adSponsoredLabel.font = sponsoredFont
        self.adView.addSubview(self.adSponsoredLabel)

        // Body
        self.adBodyLabel = UILabel.init(frame: nativeAdLayout.adBodyLabelRect)
        self.adBodyLabel.text = self.nativeAd.bodyText ?? ""
        self.adBodyLabel.textColor = self.nativeAdViewAttributes.descriptionColor
        self.adBodyLabel.font = self.nativeAdViewAttributes.descriptionFont
        self.adBodyLabel.numberOfLines = descriptionLabelLines
        self.adView.addSubview(self.adBodyLabel)

        // Button
        self.adCallToActionButton = UIButton.init(frame: nativeAdLayout.adCallToActionRect)
        self.adCallToActionButton.backgroundColor = self.nativeAdViewAttributes.buttonColor
        self.adCallToActionButton.setTitle(self.nativeAd.callToAction ?? "" , for: .normal)
        self.adCallToActionButton.setTitleColor(self.nativeAdViewAttributes.buttonTitleColor, for: .normal)
        self.adCallToActionButton.titleLabel?.font = self.nativeAdViewAttributes.buttonTitleFont
        self.adCallToActionButton.titleLabel?.textAlignment = .left
        self.adView.addSubview(self.adCallToActionButton)

        //
        self.nativeAd.unregisterView()
        self.nativeAd.registerView(
            forInteraction: self.adView,
            mediaView: self.adMediaView,
            iconView: self.adIconView,
            viewController: UIApplication.shared.keyWindow?.rootViewController,
            clickableViews: [self.adCallToActionButton, self.adMediaView]
        )

        self.adOptionsView.nativeAd = self.nativeAd

        // MainView
        self.mainView.addSubview(adView)
        self.mainView.layoutIfNeeded()
    }


    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        print("NativeAd > nativeAdDidLoad")
        self.nativeAd = nativeAd

        regNativeAdView()

        let placement_id: String = nativeAd.placementID
        let invalidated: Bool = nativeAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOADED_METHOD, arguments: arg)
    }


    func nativeAdDidDownloadMedia(_ nativeAd: FBNativeAd) {
        print("NativeAd > nativeAdDidDownloadMedia")
//        self.nativeAd = nativeAd
//
//        let placement_id: String = nativeAd.placementID
//        let invalidated: Bool = nativeAd.isAdValid
//        let arg: [String: Any] = [
//            FANConstant.PLACEMENT_ID_ARG: placement_id,
//            FANConstant.INVALIDATED_ARG: invalidated,
//        ]
//        self.channel.invokeMethod(FANConstant.LOADED_METHOD, arguments: arg)
    }


    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        print("NativeAd > nativeAdWillLogImpression")

        let placement_id: String = nativeAd.placementID
        let invalidated: Bool = nativeAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOGGING_IMPRESSION_METHOD, arguments: arg)
    }


    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        print("NativeAd > nativeAd %s", error)

        let placement_id: String = nativeAd.placementID
        let invalidated: Bool = nativeAd.isAdValid
        let errorStr: String = error as? String ?? "";
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
            FANConstant.ERROR_ARG:errorStr
        ]
        self.channel.invokeMethod(FANConstant.ERROR_METHOD, arguments: arg)
    }


    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("NativeAd > nativeAdDidClick")
        
        let placement_id: String = nativeAd.placementID
        let invalidated: Bool = nativeAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.CLICKED_METHOD, arguments: arg)
    }
}



