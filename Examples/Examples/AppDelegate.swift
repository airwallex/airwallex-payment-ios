//
//  AppDelegate.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

#if canImport(WechatOpenSDKDynamic)
import WechatOpenSDKDynamic
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //  initialize
        ExamplesKeys.loadDefaultKeysIfNilOrEmpty()
        Airwallex.setMode(ExamplesKeys.environment)
        
#if canImport(WechatOpenSDKDynamic)
        WXApi.registerApp("wx4c86d73fe4f82431", universalLink: "https://airwallex.com/")
        WXApi.startLog(by: .normal) { log in
            print("WeChat Log: \(log)")
        }
#endif
        //  customize theme color of the payment UI by setting tintColor on AWXTheme
//        AWXTheme.shared().tintColor = UIColor.systemBrown
        UISwitch.appearance().onTintColor = .awxColor(.theme)
        UIView.appearance().tintColor = .awxColor(.theme)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: PaymentResultViewController.paymentResultNotification, object: nil)
#if canImport(WechatOpenSDKDynamic)
        return WXApi.handleOpen(url, delegate: self)
#else
        return true
#endif
    }
}

#if canImport(WechatOpenSDKDynamic)
extension AppDelegate: WXApiDelegate {
    
    func onResp(_ resp: BaseResp) {
        if let response = resp as? PayResp {
            var message: String

            switch response.errCode {
            case WXSuccess.rawValue:
                message = "Succeed to pay"
            case WXErrCodeUserCancel.rawValue:
                message = "User cancelled."
            default:
                message = "Failed to pay"
            }

            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel))

            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
#endif
