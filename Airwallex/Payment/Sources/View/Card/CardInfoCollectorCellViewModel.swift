//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import AirwallexRisk

class CardInfoCollectorCellViewModel {
    var nameOnCardConfigurer: InfoCollectorTextFieldViewModel
    
    var triggerLayoutUpdate: () -> Void
    
    var cardNumberConfigurer: CardNumberTextFieldViewModel
    var expireDataConfigurer: CardExpireTextFieldViewModel
    lazy var cvcConfigurer: CardCVCTextFieldViewModel = {
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
            title: NSLocalizedString("Name on card", bundle: .payment, comment: ""),
            textFieldType: .nameOnCard
        )
    }
    
    func handleFieldDidBeginEditing(_ textField: UITextField, type: AWXTextFieldType) {
        switch type {
        case .cardNumber:
            Risk.log(event: "input_card_number", screen: "page_create_card")
        case .expires:
            Risk.log(event: "input_card_expiry", screen: "page_create_card")
        case .CVC:
            Risk.log(event: "input_card_cvc", screen: "page_create_card")
        case .nameOnCard:
            Risk.log(event: "input_card_holder_name", screen: "page_create_card")
        default:
            break
        }
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
        let arr: [any BaseTextFieldConfiguring] = [cardNumberConfigurer, expireDataConfigurer, cvcConfigurer, nameOnCardConfigurer]
        for configurer in arr {
            //  force configurer to check valid status if user left this field untouched
            configurer.handleDidEndEditing()
        }
    }
}
