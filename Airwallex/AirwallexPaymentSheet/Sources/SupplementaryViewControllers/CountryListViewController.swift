//
//  CountryListViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

protocol CountryListViewControllerDelegate: AnyObject {
    func countryListViewController(_ controller: CountryListViewController, didSelect country: AWXCountry)
}

extension AWXCountry: SearchableListItem {
    var id: String { countryCode }
    var displayText: String { countryName }
    var searchableText: String { countryName }
    var leadingImage: UIImage? {
        UIImage(named: countryCode, in: .paymentSheet, compatibleWith: nil)
    }
}

class CountryListViewController: SearchableListViewController<AWXCountry> {

    weak var delegate: CountryListViewControllerDelegate?

    var selectedCountry: AWXCountry? {
        get { selectedItem }
        set { selectedItem = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        items = AWXCountry.allCountries()
        onSelect = { [weak self] country in
            guard let self else { return }
            self.delegate?.countryListViewController(self, didSelect: country)
        }
    }
}
