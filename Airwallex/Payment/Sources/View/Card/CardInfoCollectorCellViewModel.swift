//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

class CardInfoCollectorCellViewModel: CardInfoCollectorCellConfiguring {
    var nameOnCardConfigurer: any InfoCollectorTextFieldConfiguring
    
    var triggerLayoutUpdate: () -> Void
    
    var cardNumberConfigurer: any CardNumberTextFieldConfiguring
    var expireDataConfigurer: any ErrorHintableTextFieldConfiguring
    lazy var cvcConfigurer: any ErrorHintableTextFieldConfiguring = {
        CardCVCTextFieldViewModel(maxLengthGetter: { [weak self] in
            guard let self else { return AWXCardValidator.cvcLength(for: .unknown) }
            return AWXCardValidator.cvcLength(for: self.cardNumberConfigurer.currentBrand)
        })
    }()
    
    init(cardSchemes: [AWXCardScheme], callbackForLayoutUpdate: @escaping () -> Void) {
        self.triggerLayoutUpdate = callbackForLayoutUpdate
        cardNumberConfigurer = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes
        )
        expireDataConfigurer = CardExpireTextFieldViewModel()
        nameOnCardConfigurer = InfoCollectorTextFieldViewModel(
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
    
    func createAndValidateCard() throws -> AWXCard {
        let card = AWXCard(
            name: nameOnCardConfigurer.text ?? "",
            cardNumber: cardNumberConfigurer.text ?? "",
            expiry: expireDataConfigurer.text ?? "",
            cvc: cvcConfigurer.text ?? ""
        )
        
        if let errorMessage = card.validate() {
            throw errorMessage
        }
        return card
    }
}
