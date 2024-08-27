//
//  AWXUIContext+Card.swift
//  Card
//
//  Created by Hector.Huang on 2024/8/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public extension AWXUIContext {
    @objc func presentCardPaymentFlowFrom(
        _ hostViewController: UIViewController,
        cardSchemes: [AWXCardBrand]
    ) {
        let controller = AWXCardViewController(nibName: nil, bundle: nil)
        controller.session = session
        controller.viewModel = AWXCardViewModel(
            session: session,
            supportedCardSchemes: cardSchemes.map { let cardScheme = AWXCardScheme(); cardScheme.name = $0.rawValue; return cardScheme },
            launchDirectly: true
        )
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isModalInPresentation = true
        hostViewController.present(navigationController, animated: true)
    }
    
    @objc func pushCardPaymentFlowFrom(
        _ hostViewController: UIViewController,
        cardSchemes: [AWXCardBrand]
    ) {
        let navigationController = hostViewController as? UINavigationController ?? hostViewController.navigationController
        guard let navigationController else { 
            fatalError("The hostViewController is not a navigation controller, or is not contained in a navigation controller.")
        }
        
        let controller = AWXCardViewController(nibName: nil, bundle: nil)
        controller.session = session
        controller.viewModel = AWXCardViewModel(
            session: session,
            supportedCardSchemes: cardSchemes.map { let cardScheme = AWXCardScheme(); cardScheme.name = $0.rawValue; return cardScheme },
            launchDirectly: true
        )
        
        navigationController.pushViewController(controller, animated: true)
    }
    
    @objc func presentCardPaymentFlowFrom(_ hostViewController: UIViewController) {
        presentCardPaymentFlowFrom(hostViewController, cardSchemes: [.visa, .mastercard, .amex, .discover, .dinersClub, .JCB, .unionPay])
    }
    
    @objc func pushCardPaymentFlowFrom(_ hostViewController: UIViewController) {
        pushCardPaymentFlowFrom(hostViewController, cardSchemes: [.visa, .mastercard, .amex, .discover, .dinersClub, .JCB, .unionPay])
    }
}
