//
//  AppDelegate.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Wechat ID: Stored as a user-defined variable in Project > Build Settings
    // and loaded into Info.plist URL Schemes. (Search for EXAMPLES_WECHAT_ID)
    @InfoProperty(.wechatID)
    private var wechatID: String?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Start WeChat SDK (if integrating)
        if let wechatID {
            WXApi.registerApp(wechatID, universalLink: "https://airwallex.com/")
            WXApi.startLog(by: .normal) { log in
                print("WeChat Log: \(log)")
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        WXApi.handleOpen(url, delegate: self)
    }
}

extension AppDelegate: WXApiDelegate {
    func onResp(_ resp: BaseResp) {
        if let payResponse = resp as? PayResp {
            switch payResponse.errCode {
            case WXSuccess.rawValue:
                print("WeChat Log: WeChat SDK payment succeeded.")
            case WXErrCodeUserCancel.rawValue:
                print("WeChat Log: WeChat SDK payment canceled.")
            default:
                print("WeChat Log: WeChat SDK payment failed")
            }
        }
    }
}
