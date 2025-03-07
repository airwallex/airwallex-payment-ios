//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

class CardInfoCollectorCellViewModel {
    var nameOnCardConfigurer: InfoCollectorTextFieldViewModel!
    
    var reconfigureHandler: (CardInfoCollectorCellViewModel, Bool) -> Void
    
    var cardNumberConfigurer: CardNumberTextFieldViewModel!
    var expireDataConfigurer: CardExpireTextFieldViewModel!
    var cvcConfigurer: CardCVCTextFieldViewModel!
    
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
    init(cardSchemes: [AWXCardScheme],
         reconfigureHandler: @escaping (CardInfoCollectorCellViewModel, Bool) -> Void) {
        self.reconfigureHandler = reconfigureHandler
        cardNumberConfigurer = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes,
            reconfigureHandler: { [weak self] _, layoutUpdate in
                guard let self else { return }
                self.reconfigureHandler(self, layoutUpdate)
            }
        )
        expireDataConfigurer = CardExpireTextFieldViewModel(
            reconfigureHandler: { [weak self] _, layoutUpdate in
                guard let self else { return }
                self.reconfigureHandler(self, layoutUpdate)
            }
        )
        
        cvcConfigurer = CardCVCTextFieldViewModel(
            cvcValidator: CardCVCValidator { [weak self] in
                guard let self else { return AWXCardValidator.cvcLength(for: .unknown) }
                return AWXCardValidator.cvcLength(for: self.cardNumberConfigurer.currentBrand)
            },
            reconfigureHandler: { [weak self] _, layoutUpdate in
                guard let self else { return }
                self.reconfigureHandler(self, layoutUpdate)
            }
        )
        nameOnCardConfigurer = InfoCollectorTextFieldViewModel(
            title: NSLocalizedString("Name on card", bundle: .payment, comment: ""),
            textFieldType: .nameOnCard,
            reconfigureHandler: { [weak self] viewModel, layoutUpdates in
                guard let self else { return }
                self.reconfigureHandler(self, layoutUpdates)
            }
        )
    }
    
    func handleFieldDidBeginEditing(_ textField: UITextField, type: AWXTextFieldType) {
        switch type {
        case .cardNumber:
            RiskLogger.log(.inputCardNumber, screen: .createCard)
        case .expires:
            RiskLogger.log(.inputCardExpiry, screen: .createCard)
        case .CVC:
            RiskLogger.log(.inputCardCVC, screen: .createCard)
        case .nameOnCard:
            RiskLogger.log(.inputCardHolderName, screen: .createCard)
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
//            configurer.handleDidEndEditing()
            configurer.textFieldDidEndEditing?(UITextField())
            // TODO:  try optimize this
        }
    }
}
