//
//  UIStoryboardUtils.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    func createOptionsViewController() -> UIViewController? {
        if let optionsVC = instantiateViewController(withIdentifier: "options") as? OptionsViewController {
            optionsVC.customerFetcher = DemoStoreAPIClient()
            return optionsVC
        }
        return nil
    }
    
    static func instantiateHTML5DemoController() -> UIViewController? {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let demoVC = mainStoryboard.instantiateViewController(withIdentifier: "h5demo") as? InputViewController else {
            return nil
        }
        return demoVC
    }
    
    static func instantiateWeChatDemoController() -> UIViewController? {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let demoVC = mainStoryboard.instantiateViewController(withIdentifier: "wechatdemo") as? WechatPayViewController else {
            return nil
        }
        return demoVC
    }
}
