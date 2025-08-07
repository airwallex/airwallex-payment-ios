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
        
        disableAnimationForUITesting()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: PaymentResultViewController.paymentResultNotification, object: nil)
#if canImport(WechatOpenSDKDynamic)
        if WXApi.handleOpen(url, delegate: self) {
            return true
        } else {
            return handleAirwallexDemoSchema(url)
        }
#else
        return handleSchemaURL(url)
#endif
    }
    
    private func handleAirwallexDemoSchema(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == String.demoAppScheme,
              components.host == String.demoAppHost,
              let type = components.queryItems?.first(where: { $0.name == "type"})?.value else {
            return false
        }
        switch type {
        case "SUCCESS_URL":
            let intentId = components.queryItems?.first(where: { $0.name == "id"})?.value ?? "Not Found"
            window?.rootViewController?.showAlert(message: "intentId: \(intentId)", title: "Payment Success")
        default:
            window?.rootViewController?.showAlert(message: url.absoluteString, title: type)
        }
        return true
    }
    
    fileprivate func disableAnimationForUITesting() {
        if ProcessInfo.processInfo.environment[UITestingEnvironmentVariable.isUITesting] == "1" {
            // disable animation for robust UI testing
            UIView.setAnimationsEnabled(false)
            UIWindow.appearance().layer.speed = 100
            CATransaction.setAnimationDuration(0)
            UIApplication.shared.keyWindow?.layer.speed = 100
        }
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
