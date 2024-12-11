//
//  PaymentMethodsViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

class PaymentMethodsViewController: AWXViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "close", in: Bundle.resource())
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(foo)
        )
        navigationItem.title = "DEMO CHECKOUT"
    }
    
    @objc
    public func foo() {
        AWXUIContext.shared().delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
    }
}


extension PaymentMethodsViewController: AWXPageViewTrackable {
    var pageName: String! {
        "payment_method_list"
    }
    
    
}
