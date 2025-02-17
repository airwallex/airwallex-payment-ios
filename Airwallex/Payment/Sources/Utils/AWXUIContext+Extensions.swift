//
//  AWXUIContext+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

public extension AWXUIContext {
    enum LaunchStyle {
        case push
        case present
    }
    
    @MainActor func launchPayment(from hostingVC: UIViewController, style: LaunchStyle = .push) {
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
            AWXUIContext.shared().paymentUIDismissAction = { [weak hostingVC, weak nav] completion in
                guard let hostingVC, let nav else {
                    completion?()
                    return
                }
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    completion?()
                }
                nav.popToViewController(hostingVC, animated: true)
                CATransaction.commit()
            }
        case .present:
            let nav = UINavigationController(rootViewController: paymentVC)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.awxBackgroundHighlight // Set your desired color
            appearance.shadowColor = UIColor.awxBorderDecorative
            
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
            nav.navigationBar.compactAppearance = appearance
            hostingVC.present(nav, animated: true)
            AWXUIContext.shared().paymentUIDismissAction = { [weak nav] completion in
                guard let nav else {
                    completion?()
                    return
                }
                nav.dismiss(animated: true) {
                    completion?()
                }
            }
        }
    }
}
