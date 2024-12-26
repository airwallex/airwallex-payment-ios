//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

class PaymentCardInfoCellViewModel: PaymentCardInfoCellConfiguring {
    var nameOnCardConfigurer: any InformativeUserInputViewConfiguring
    
    var callbackForLayoutUpdate: () -> Void
    
    var cardNumberConfigurer: any CardNumberInputViewConfiguring
    var expireDataConfigurer: any ErrorHintableTextFieldConfiguring
    var cvcConfigurer: any ErrorHintableTextFieldConfiguring
    
    init(cardSchemes: [AWXCardScheme], callbackForLayoutUpdate: @escaping () -> Void) {
        self.callbackForLayoutUpdate = callbackForLayoutUpdate
        cardNumberConfigurer = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes
        )
        expireDataConfigurer = ExpireDataTextFieldViewModel()
        cvcConfigurer = CVCTextFieldViewModel()
        nameOnCardConfigurer = InformativeUserInputViewModel(
            title: NSLocalizedString("Name on card", bundle: .payment, comment: "")
        )
    }
    
    var errorHintForCardFields: String? {
        for configurer in [ cardNumberConfigurer, expireDataConfigurer, cvcConfigurer ] {
            if let configurer = configurer as? ErrorHintableTextFieldConfiguring,
               let errorHint = configurer.errorHint,
               !configurer.isValid {
                return errorHint
            }
        }
        
        return nil
    }
}
