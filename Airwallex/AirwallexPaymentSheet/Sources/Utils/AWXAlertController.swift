//
//  AWXAlertController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

class AWXAlertController: UIAlertController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        UIView.appearance(whenContainedInInstancesOf: [AWXAlertController.self]).tintColor = .awxColor(.theme)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    
    func showAlert(
        title: String? = nil,
        message: String? = nil,
        language: AWXPaymentLanguage = .english,
        action: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = AWXAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Close", bundle: .paymentSheet.language(language), comment: "close button for alert"),
                style: .cancel,
                handler: action
            )
        )
        present(alert, animated: true)
    }
}
