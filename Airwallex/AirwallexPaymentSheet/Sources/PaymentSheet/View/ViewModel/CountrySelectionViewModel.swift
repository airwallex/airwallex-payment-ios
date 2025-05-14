//
//  CountrySelectionViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/8.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif

class CountrySelectionViewModel: InfoCollectorTextFieldViewModel, OptionSelectionViewConfiguring {
    var country: AWXCountry? {
        didSet {
            text = country?.countryDescription
            handleDidEndEditing(reconfigureStrategy: .always)
        }
    }
    
    var icon: UIImage? = nil
    
    var indicator: UIImage? {
        UIImage(named: "down", in: .paymentSheet)?
            .withTintColor(
                isEnabled ? .awxColor(.iconSecondary) : .awxColor(.iconDisabled),
                renderingMode: .alwaysOriginal
            )
    }
    
    var handleUserInteraction: () -> Void
    
    init(country: AWXCountry?,
         fieldName: String = "country",
         title: String? = nil,
         isEnabled: Bool = true,
         hideErrorHintLabel: Bool = true,
         handleUserInteraction: @escaping () -> Void,
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.country = country
        self.handleUserInteraction = handleUserInteraction
        super.init(
            fieldName: fieldName,
            title: title,
            text: country?.countryDescription,
            placeholder: NSLocalizedString("Select...", bundle: .paymentSheet, comment: "country selection view placeholder"),
            isRequired: true,
            isEnabled: isEnabled,
            hideErrorHintLabel: hideErrorHintLabel,
            reconfigureHandler: reconfigureHandler
        )
        inputValidator = BlockValidator { [weak self] _ in
            guard let self else { return }
            guard self.country != nil else {
                throw NSLocalizedString(
                    "Please enter your country",
                    bundle: .paymentSheet,
                    comment: "country selection view error hint"
                ).asError()
            }
        }
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        assert(false, "should never trigger")
        return false
    }
}

fileprivate extension AWXCountry {
    var countryDescription: String {
        if let flag = String.flagEmoji(countryCode: countryCode) {
            return flag + " " + countryName
        } else {
            return countryName
        }
    }
}

class CountrySelectionCellViewModel: CountrySelectionViewModel, CellViewModelIdentifiable {
    let itemIdentifier: String
    
    init(country: AWXCountry?,
         itemIdentifier: String,
         fieldName: String = "country",
         title: String? = nil,
         isEnabled: Bool = true,
         handleUserInteraction: @escaping () -> Void,
         cellReconfigureHandler: @escaping CellReconfigureHandler) {
        self.itemIdentifier = itemIdentifier
        super.init(
            country: country,
            fieldName: fieldName,
            title: title,
            isEnabled: isEnabled,
            hideErrorHintLabel: false,
            handleUserInteraction: handleUserInteraction,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
    }
}
