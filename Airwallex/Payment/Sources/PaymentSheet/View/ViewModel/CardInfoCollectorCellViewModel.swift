//
//  PaymentCardinfoCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(Core)
import Core
#endif

class CardInfoCollectorCellViewModel: CellViewModelIdentifiable {
    
    var itemIdentifier: String
    
    var cardNumberConfigurer: CardNumberTextFieldViewModel!
    var expireDataConfigurer: InfoCollectorTextFieldViewModel!
    var cvcConfigurer: InfoCollectorTextFieldViewModel!
    
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
    init(itemIdentifier: String,
         cardSchemes: [AWXCardScheme],
         returnActionHandler: CellReturnActionHandler?,
         reconfigureHandler: @escaping CellReconfigureHandler) {
        self.itemIdentifier = itemIdentifier
        cardNumberConfigurer = CardNumberTextFieldViewModel(
            supportedCardSchemes: cardSchemes,
            editingEventObserver: BeginEditingEventObserver {
                RiskLogger.log(.inputCardNumber, screen: .createCard)
            },
            reconfigureHandler: { reconfigureHandler(itemIdentifier, $1) }
        )
        expireDataConfigurer = InfoCollectorTextFieldViewModel(
            textFieldType: .expires,
            placeholder: "MM / YY",
            customInputFormatter: CardExpiryFormatter(),
            customInputValidator: CardExpiryValidator(),
            editingEventObserver: BeginEditingEventObserver {
                RiskLogger.log(.inputCardExpiry, screen: .createCard)
            },
            reconfigureHandler: { reconfigureHandler(itemIdentifier, $1) }
        )
        
        cvcConfigurer = InfoCollectorTextFieldViewModel(
            returnActionHandler: { [weak self] textField in
                guard let self, let returnActionHandler else {
                    return false
                }
                return returnActionHandler(textField, self.itemIdentifier)
            },
            cvcValidator: CardCVCValidator { [weak self] in
                guard let self else { return AWXCardValidator.cvcLength(for: .unknown) }
                return AWXCardValidator.cvcLength(for: self.cardNumberConfigurer.currentBrand)
            },
            editingEventObserver: BeginEditingEventObserver {
                RiskLogger.log(.inputCardCVC, screen: .createCard)
            },
            reconfigureHandler: { reconfigureHandler(itemIdentifier, $1) }
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
