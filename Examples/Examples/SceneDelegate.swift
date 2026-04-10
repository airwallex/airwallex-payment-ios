//
//  SceneDelegate.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

#if canImport(WechatOpenSDKDynamic)
import WechatOpenSDKDynamic
#endif

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        disableAnimationForUITesting()
        // Handle URLs passed at launch
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }

    private func handleURL(_ url: URL) {
        NotificationCenter.default.post(name: PaymentResultViewController.paymentResultNotification, object: nil)
#if canImport(WechatOpenSDKDynamic)
        if !WXApi.handleOpen(url, delegate: self) {
            handleAirwallexDemoSchema(url)
        }
#else
        handleAirwallexDemoSchema(url)
#endif
    }

    private func handleAirwallexDemoSchema(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == String.demoAppScheme,
              components.host == String.demoAppHost else {
            return
        }
        guard let type = components.queryItems?.first(where: { $0.name == "type" })?.value else {
            print("APP launched by URL: \(url.absoluteString)")
            return
        }

        switch type {
        case "SUCCESS_URL":
            let intentId = components.queryItems?.first(where: { $0.name == "id" })?.value ?? "Not Found"
            window?.rootViewController?.showAlert(message: "intentId: \(intentId)", title: "Payment Success") {
                UIPasteboard.general.string = intentId
            }
        case "FAIL_URL":
            let intentId = components.queryItems?.first(where: { $0.name == "id" })?.value ?? "Not Found"
            let error = components.queryItems?.first(where: { $0.name == "error" })?.value ?? "Not Found"
            window?.rootViewController?.showAlert(message: "error: \(error), intentId: \(intentId)", title: "Payment Failed") {
                UIPasteboard.general.string = intentId
            }
        default:
            window?.rootViewController?.showAlert(message: url.absoluteString, title: type)
        }
    }

    private func disableAnimationForUITesting() {
        if ProcessInfo.processInfo.environment[UITestingEnvironmentVariable.isUITesting] == "1" {
            UIView.setAnimationsEnabled(false)
            UIWindow.appearance().layer.speed = 100
            CATransaction.setAnimationDuration(0)
            window?.layer.speed = 100
        }
    }
}

#if canImport(WechatOpenSDKDynamic)
extension SceneDelegate: WXApiDelegate {

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

            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}
#endif
