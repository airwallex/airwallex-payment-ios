//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

class CardInfoCollectorCellViewModel {
    
    var reconfigureHandler: (CardInfoCollectorCellViewModel, Bool) -> Void
    
    var cardNumberConfigurer: CardNumberTextFieldViewModel!
    var expireDataConfigurer: InfoCollectorTextFieldViewModel!
    var cvcConfigurer: InfoCollectorTextFieldViewModel!
    /// used to handle auto return action for last text field, CVC text field
    var returnActionHandler: ((UITextField) -> Void)?
    
    var errorHintForCardFields: String? {
        for configurer in [ cardNumberConfigurer, expireDataConfigurer, cvcConfigurer ] {
            if let configurer,
               let errorHint = configurer.errorHint,
               !configurer.isValid {
                return errorHint
            }
        }
        
        return nil
    }
    // MARK: -
    init(cardSchemes: [AWXCardScheme],
         returnActionHandler: ((UITextField) -> Void)?,
         reconfigureHandler: @escaping (CardInfoCollectorCellViewModel, Bool) -> Void) {
        self.returnActionHandler = returnActionHandler
        self.reconfigureHandler = reconfigureHandler
        cardNumberConfigurer = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes,
            editingEventObserver: BeginEditingEventObserver {
                RiskLogger.log(.inputCardNumber, screen: .createCard)
            },
            reconfigureHandler: { [weak self] _, layoutUpdate in
                guard let self else { return }
                self.reconfigureHandler(self, layoutUpdate)
            }
        )
        expireDataConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .expires,
            placeholder: "MM / YY",
            customInputFormatter: CardExpiryFormatter(),
            customInputValidator: CardExpiryValidator(),
            editingEventObserver: BeginEditingEventObserver {
                RiskLogger.log(.inputCardExpiry, screen: .createCard)
            },
            reconfigureHandler: { [weak self] _, layoutUpdate in
                guard let self else { return }
                self.reconfigureHandler(self, layoutUpdate)
            }
        )
        
        cvcConfigurer = InfoCollectorTextFieldViewModel(
            returnActionHandler: { [weak self] textField in
                guard let self, let handler = self.returnActionHandler else { return }
                handler(textField)
            },
            cvcValidator: CardCVCValidator { [weak self] in
                guard let self else { return AWXCardValidator.cvcLength(for: .unknown) }
                return AWXCardValidator.cvcLength(for: self.cardNumberConfigurer.currentBrand)
            },
            editingEventObserver: BeginEditingEventObserver {
                RiskLogger.log(.inputCardCVC, screen: .createCard)
            },
            reconfigureHandler: { [weak self] _, layoutUpdate in
                guard let self else { return }
                self.reconfigureHandler(self, layoutUpdate)
            }
        )
    }
}

extension CardInfoCollectorCellViewModel {
    func cardFromCollectedInfo() -> AWXCard {
        let card = AWXCard(
            name: "",
            cardNumber: cardNumberConfigurer.text ?? "",
            expiry: expireDataConfigurer.text ?? "",
            cvc: cvcConfigurer.text ?? ""
        )
        return card
    }
    
    func updateValidStatusForCheckout() {
        let arr: [InfoCollectorTextFieldViewModel] = [cardNumberConfigurer, expireDataConfigurer, cvcConfigurer]
        for configurer in arr {
            //  force configurer to check valid status if user left this field untouched
            configurer.handleDidEndEditing(reconfigureIfNeeded: true)
        }
    }
}

extension CardInfoCollectorCellViewModel: ViewModelValidatable {
    func validate() throws {
        for configurer in [cardNumberConfigurer, expireDataConfigurer, cvcConfigurer] {
            try configurer?.validate()
        }
    }
}
