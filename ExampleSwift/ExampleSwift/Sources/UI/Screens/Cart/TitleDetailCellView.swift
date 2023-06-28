//
//  TitleDetailCellView.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 26/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit

class TitleDetailCellView: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!
    
    func populate(title: String, detail: String?) {
        self.titleLabel.text = title
        self.detailLabel.text = detail
    }
}
