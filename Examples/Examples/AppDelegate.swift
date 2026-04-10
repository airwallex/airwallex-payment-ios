//
//  AppDelegate.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

#if canImport(WechatOpenSDKDynamic)
import WechatOpenSDKDynamic
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

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

        UISwitch.appearance().onTintColor = .awxColor(.theme)
        UIView.appearance().tintColor = .awxColor(.theme)
//        AnalyticsLogger.shared().verbose = true

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
