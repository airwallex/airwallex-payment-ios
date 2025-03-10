//
//  CardNumberTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardNumberTextFieldViewModel: InfoCollectorTextFieldViewModel, CardNumberTextFieldConfiguring {
    let supportedBrands = AWXBrandType.supportedBrands
    
    var currentBrand: AWXBrandType {
        return formatter.currentBrand
    }
    
    private let formatter = CardNumberFormatter()
    
    init(supportedCardSchemes: [AWXCardScheme],
         reconfigureHandler: @escaping ReconfigureHandler) {
        super.init(
            textFieldType: .cardNumber,
            placeholder: "1234 1234 1234 1234",
            customInputFormatter: formatter,
            customInputValidator: CardNumberValidator(supportedCardSchemes: supportedCardSchemes),
            reconfigureHandler: reconfigureHandler
        )
    }
}
