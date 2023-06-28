//
//  UIViewController+Extensions.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 14/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func dequeueCell<T: UITableViewCell>(
        at indexPath: IndexPath,
        in tableView: UITableView
    ) -> T {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T else {
            preconditionFailure("Unable to dequeue cell at \(indexPath)")
        }
        return cell
    }
}
