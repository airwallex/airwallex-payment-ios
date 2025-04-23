//
//  CardNumberTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif

class CardNumberTextFieldViewModel: InfoCollectorTextFieldViewModel, CardBrandViewConfiguring {
    let supportedBrands: [AWXBrandType]
    var currentBrand: AWXBrandType {
        if supportedBrands.contains(formatter.currentBrand) {
            return formatter.currentBrand
        } else {
            return .unknown
        }
    }
    
    var cardBrands: [AWXBrandType] {
        if (text ?? "").isEmpty {
            return supportedBrands
        }
        return formatter.candidates.filter { supportedBrands.contains($0) }
    }
    
    private let formatter: CardNumberFormatter
    
    init(supportedCardSchemes: [AWXCardScheme],
         editingEventObserver: EditingEventObserver?,
         reconfigureHandler: @escaping ReconfigureHandler) {
        supportedBrands = supportedCardSchemes.map { $0.brandType }
        formatter = CardNumberFormatter(candidates: supportedBrands)
        super.init(
            textFieldType: .cardNumber,
            placeholder: "1234 1234 1234 1234",
            customInputFormatter: formatter,
            customInputValidator: CardNumberValidator(supportedCardSchemes: supportedCardSchemes),
            editingEventObserver: editingEventObserver,
            reconfigureHandler: reconfigureHandler
        )
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let _ = super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        // force reconfigure to update current card brand logo on the right of the text field
        reconfigureHandler(self, false)
        return false
    }
}
