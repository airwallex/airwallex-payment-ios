//
//  SubdivisionListViewController.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

extension SubdivisionOption: SearchableListItem {
    var id: String { value }
    var displayText: String { label }
    var searchableText: String { "\(value) \(label)" }
}

protocol SubdivisionListViewControllerDelegate: AnyObject {
    func subdivisionListViewController(_ controller: SubdivisionListViewController, didSelect option: SubdivisionOption)
}

class SubdivisionListViewController: SearchableListViewController<SubdivisionOption> {

    weak var delegate: SubdivisionListViewControllerDelegate?

    var selectedOption: SubdivisionOption? {
        get { selectedItem }
        set { selectedItem = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        onSelect = { [weak self] option in
            guard let self else { return }
            self.delegate?.subdivisionListViewController(self, didSelect: option)
        }
    }
}
