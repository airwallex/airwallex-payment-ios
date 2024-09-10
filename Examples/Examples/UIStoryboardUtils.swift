//
//  UIStoryboardUtils.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

extension UIStoryboard {
    @objc func createCartViewController() -> UIViewController? {
        if let navController = instantiateInitialViewController() as? UINavigationController, let cartVC = navController.topViewController as? CartViewController {
            cartVC.apiClient = DemoStoreAPIClient()
            navController.viewControllers = [cartVC]
            return navController
        }
        return nil
    }
    
    func createOptionsViewController() -> UIViewController? {
        if let optionsVC = instantiateViewController(withIdentifier: "options") as? OptionsViewController {
            optionsVC.customerFetcher = DemoStoreAPIClient()
            return optionsVC
        }
        return nil
    }
}
