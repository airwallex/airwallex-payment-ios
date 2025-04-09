//
//  CardNumberTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#elseif canImport(AirwallexCore)
import AirwallexCore
#endif

class CardNumberTextFieldViewModel: InfoCollectorTextFieldViewModel, CardNumberTextFieldConfiguring {
    let supportedBrands: [AWXBrandType]
    var currentBrand: AWXBrandType {
        return formatter.currentBrand
    }
    
    private let formatter = CardNumberFormatter()
    
    init(supportedCardSchemes: [AWXCardScheme],
         editingEventObserver: UserEditingEventObserver?,
         reconfigureHandler: @escaping ReconfigureHandler) {
        supportedBrands = supportedCardSchemes.map { $0.brandType }
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
