//
//  CartProductCellView.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 26/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit

class CartProductCellView: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!
    
    func populate(product: Product) {
        self.titleLabel.text = product.name
        self.subtitleLabel.text = product.description
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        self.detailLabel.text = numberFormatter.string(from: product.unitPrice as NSNumber)
    }
}
