//
//  CartViewController+TableView.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/6.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : products.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 9 : 24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        section == 0 ? nil : UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingCell", for: indexPath) as! ShippingCell
            if let shipping {
                cell.shipping = shipping
            }
            return cell
        }
        
        if (self.products.count == indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
            let subtotal = products.map { $0.price }.reduce(NSDecimalNumber.zero) { $0.adding($1) }
            cell.subtotal = subtotal
            cell.shipping = 0
            cell.total = subtotal
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.product = products[indexPath.row]
        cell.handler = { [weak self] product in
            self?.products.removeAll(where: { $0 == product })
            self?.reloadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0) {
            let controller = AWXShippingViewController(nibName: nil, bundle: nil)
            controller.delegate = self
            controller.shipping = shipping
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension CartViewController: AWXShippingViewControllerDelegate {
    func shippingViewController(_ controller: AWXShippingViewController, didEditShipping shipping: AWXPlaceDetails) {
        navigationController?.popViewController(animated: true)
        self.shipping = shipping
        reloadData()
    }
}
