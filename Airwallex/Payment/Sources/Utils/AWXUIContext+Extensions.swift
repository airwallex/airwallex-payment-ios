//
//  AWXUIContext+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

// Debug
fileprivate var foo = true

public extension AWXUIContext {
    @MainActor func presentPaymentViewController(from hostingVC: UIViewController) {
        foo.toggle()
        //          wpdebug - old UI flow
        if foo {
            presentEntirePaymentFlow(from: hostingVC)
            return
        }
        
        let viewModel = AWXPaymentMethodListViewModel(
            session: session,
            apiClient: AWXAPIClient(configuration: AWXAPIClientConfiguration.shared())
        )
        let provider = PaymentMethodProvider(provider: viewModel)
        let paymentVC = PaymentMethodsViewController(methodProvider: provider)
        let nav = UINavigationController(rootViewController: paymentVC)
        nav.modalPresentationStyle = .fullScreen
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.awxBackgroundHighlight // Set your desired color
        appearance.shadowColor = UIColor.awxBorderDecorative
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.compactAppearance = appearance
        hostingVC.present(nav, animated: true)
    }
    
    @MainActor func launchPaymentList(from hostingVC: UIViewController, style: AWXPaymentLaunchStyle = .push) {
        AWXUIContext.shared().launchStyle = style
        let viewModel = AWXPaymentMethodListViewModel(
            session: session,
            apiClient: AWXAPIClient(configuration: AWXAPIClientConfiguration.shared())
        )
        let provider = PaymentMethodProvider(provider: viewModel)
        let paymentVC = PaymentMethodsViewController(methodProvider: provider)
        
        switch style {
        case .push:
            guard let nav = hostingVC.navigationController else {
                fallthrough
            }
            nav.pushViewController(paymentVC, animated: true)
        case .present:
            let nav = UINavigationController(rootViewController: paymentVC)
//            nav.modalPresentationStyle = .fullScreen
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.awxBackgroundHighlight // Set your desired color
            appearance.shadowColor = UIColor.awxBorderDecorative
            
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
            nav.navigationBar.compactAppearance = appearance
            hostingVC.present(nav, animated: true)
        }
    }
}
