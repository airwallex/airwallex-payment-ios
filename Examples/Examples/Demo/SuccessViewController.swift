//
//  SuccessViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/12.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class SuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .awxBackgroundPrimary

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.center = view.center
        label.text = "Pay Result"
        label.textColor = .awxTextPrimary
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        
        view.addSubview(label)
    }
}
