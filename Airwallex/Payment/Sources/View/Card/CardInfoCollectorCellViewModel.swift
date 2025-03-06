//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

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
            RiskEvent.log(.inputCardNumber, screen: .createCard)
        case .expires:
            RiskEvent.log(.inputCardExpiry, screen: .createCard)
        case .CVC:
            RiskEvent.log(.inputCardCVC, screen: .createCard)
        case .nameOnCard:
            RiskEvent.log(.inputCardHolderName, screen: .createCard)
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
