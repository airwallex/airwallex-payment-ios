//
//  PaymentResultViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/12.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class PaymentResultViewController: UIViewController {
    
    static let paymentResultNotification = Notification.Name(rawValue: "showPaymentResultVC")
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(
            title: NSLocalizedString("Payment Result", comment: "")
        )
        view.setup(viewModel)
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You will need to check payment status from backend or deeplink url and show the result."
        label.textColor = .awxColor(.textPrimary)
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.addSubview(topView)
        view.addSubview(label)
        view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let constraints = [
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
