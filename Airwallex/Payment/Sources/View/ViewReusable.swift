//
//  ViewReusable.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

protocol ViewReusable: UIView {
    static var reuseIdentifier: String { get }
}

extension ViewReusable {
    static var reuseIdentifier: String {
        return String(String(describing: self))
    }
}

protocol ViewConfigurable: UIView {
    associatedtype ViewModel
    var viewModel: ViewModel? { get }
    func setup(_ viewModel: ViewModel)
}

extension ViewConfigurable {
    func reconfigure() {
        guard let viewModel else { return }
        setup(viewModel)
    }
}
