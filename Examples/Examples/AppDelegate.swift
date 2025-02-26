//
//  AppDelegate.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //  initialize
        ExamplesKeys.loadDefaultKeysIfNilOrEmpty()
        Airwallex.setMode(ExamplesKeys.environment)
        
        
        WXApi.registerApp("wx4c86d73fe4f82431", universalLink: "https://airwallex.com/")
        WXApi.startLog(by: .normal) { log in
            print("WeChat Log: \(log)")
        }
        //  customize theme color of the payment UI by setting tintColor on AWXTheme
        AWXTheme.shared().tintColor = UIColor.systemBrown
        UISwitch.appearance().onTintColor = .awxColor(.theme)
        UIView.appearance().tintColor = .awxColor(.theme)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: PaymentResultViewController.paymentResultNotification, object: nil)
        return WXApi.handleOpen(url, delegate: self)
    }
}

extension AppDelegate: WXApiDelegate {
    
    func onResp(_ resp: BaseResp) {
        if let response = resp as? PayResp {
            var message: String

            switch response.errCode {
            case WXSuccess.rawValue:
                message = NSLocalizedString("Succeed to pay", comment: "")
            case WXErrCodeUserCancel.rawValue:
                message = NSLocalizedString("User cancelled.", comment: "")
            default:
                message = NSLocalizedString("Failed to pay", comment: "")
            }

            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))

            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
