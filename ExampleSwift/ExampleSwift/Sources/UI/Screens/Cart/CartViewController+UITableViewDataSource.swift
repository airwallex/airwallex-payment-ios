//
//  CartViewController+UITableViewDataSource.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 26/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit

extension CartViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // shipping info
            return 1
        case 1:
            // products + total
            return viewModel.products.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            // shipping section
            let cell: TitleDetailCellView = dequeueCell(at: indexPath, in: tableView)
            cell.populate(
                title: NSLocalizedString("Shipping", comment: ""),
                detail: viewModel.shipping.description
            )
            return cell
        case 1:
            // product + total section
            let productsCount = viewModel.products.count
            
            if indexPath.row < productsCount {
                // product row
                let cell: CartProductCellView = dequeueCell(at: indexPath, in: tableView)
                let product = viewModel.products[indexPath.row]
                cell.populate(product: product)
                return cell
            } else {
                // total
                let cell: TitleDetailCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Total", comment: ""),
                    detail: viewModel.formattedTotalAmount
                )
                return cell
            }
        default:
            preconditionFailure("Unexpected indexPath in table view \(indexPath)")
        }
    }
}

