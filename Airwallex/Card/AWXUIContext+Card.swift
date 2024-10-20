//
//  AWXUIContext+Card.swift
//  Card
//
//  Created by Hector.Huang on 2024/8/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public extension AWXUIContext {
    /**
     Present the card payment flow.
     */
    @objc func presentCardPaymentFlow(
        from hostViewController: UIViewController,
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
    
    /**
     Push the card payment flow.
     */
    @objc func pushCardPaymentFlow(
        from hostViewController: UIViewController,
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
    
    @objc func presentCardPaymentFlow(from hostViewController: UIViewController) {
        presentCardPaymentFlow(from: hostViewController, cardSchemes: [.visa, .mastercard, .amex, .discover, .dinersClub, .JCB, .unionPay])
    }
    
    @objc func pushCardPaymentFlow(from hostViewController: UIViewController) {
        pushCardPaymentFlow(from: hostViewController, cardSchemes: [.visa, .mastercard, .amex, .discover, .dinersClub, .JCB, .unionPay])
    }
}
