//
//  AWXAlertController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

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
        action: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = AWXAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Close", bundle: .paymentSheet, comment: ""),
                style: .cancel,
                handler: action
            )
        )
        present(alert, animated: true)
    }
}
