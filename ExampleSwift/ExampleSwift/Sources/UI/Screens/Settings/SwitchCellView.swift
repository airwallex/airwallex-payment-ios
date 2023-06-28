//
//  SwitchCellView.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 14/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit

class SwitchCellView: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var toggleSwitch: UISwitch!
    private var onValueChanged: ((Bool) -> Void)?
    
    func populate(title: String, isOn: Bool, onValueChanged: @escaping (Bool) -> Void) {
        self.titleLabel.text = title
        self.toggleSwitch.isOn = isOn
        self.onValueChanged = onValueChanged
    }
    
    @IBAction func didToggleSwitch(_ sender: UISwitch) {
        onValueChanged?(sender.isOn)
    }
}
