//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

class PaymentCardInfoCellViewModel: PaymentCardInfoCellConfiguring {
    var cardNumberConfigurer: any CardNumberInputViewConfiguring
    var expireDataConfigurer: any ErrorHintableTextFieldConfiguring
    var cvcConfigurer: any ErrorHintableTextFieldConfiguring
    
    init(cardSchemes: [AWXCardScheme]) {
        cardNumberConfigurer = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes
        )
        expireDataConfigurer = ExpireDataTextFieldViewModel()
        cvcConfigurer = CVCTextFieldViewModel()
    }
}
