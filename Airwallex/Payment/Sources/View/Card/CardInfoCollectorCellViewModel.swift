//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

class CardInfoCollectorCellViewModel: CardInfoCollectorCellConfiguring {
    // MARK: CardInfoCollectorCellConfiguring
    var nameOnCardConfigurer: any InfoCollectorTextFieldConfiguring
    
    var triggerLayoutUpdate: () -> Void
    
    var cardNumberConfigurer: any CardNumberTextFieldConfiguring
    var expireDataConfigurer: any BaseTextFieldConfiguring
    lazy var cvcConfigurer: any BaseTextFieldConfiguring = {
        CardCVCTextFieldViewModel(maxLengthGetter: { [weak self] in
            guard let self else { return AWXCardValidator.cvcLength(for: .unknown) }
            return AWXCardValidator.cvcLength(for: self.cardNumberConfigurer.currentBrand)
        })
    }()
    
    var errorHintForCardFields: String? {
        for configurer in [ cardNumberConfigurer, expireDataConfigurer, cvcConfigurer ] {
            if let configurer = configurer as? BaseTextFieldConfiguring,
               let errorHint = configurer.errorHint,
               !configurer.isValid {
                return errorHint
            }
        }
        
        return nil
    }
    // MARK: -
    init(cardSchemes: [AWXCardScheme], callbackForLayoutUpdate: @escaping () -> Void) {
        triggerLayoutUpdate = callbackForLayoutUpdate
        cardNumberConfigurer = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes
        )
        expireDataConfigurer = CardExpireTextFieldViewModel()
        nameOnCardConfigurer = InfoCollectorTextFieldViewModel(
            fieldName: "nameOnCard",
            title: NSLocalizedString("Name on card", bundle: .payment, comment: "")
        )
    }
}

extension CardInfoCollectorCellViewModel {
    func cardFromCollectedInfo() -> AWXCard {
        let card = AWXCard(
            name: nameOnCardConfigurer.text ?? "",
            cardNumber: cardNumberConfigurer.text ?? "",
            expiry: expireDataConfigurer.text ?? "",
            cvc: cvcConfigurer.text ?? ""
        )
        return card
    }
    
    func updateValidStatusForCheckout() {
        for configurer in [cardNumberConfigurer, expireDataConfigurer, cvcConfigurer, nameOnCardConfigurer] {
            //  force configurer to check valid status if user left this field untouched
            configurer.handleDidEndEditing()
        }
    }
}
