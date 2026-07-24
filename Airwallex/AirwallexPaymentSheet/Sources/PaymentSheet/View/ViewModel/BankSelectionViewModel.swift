//
//  BankSelectionViewModel.swift
//  Core
//
//  Created by Weiping Li on 2025/1/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

class BankSelectionViewModel: InfoCollectorTextFieldViewModel, OptionSelectionViewConfiguring {
    
    var bank: AWXBank? {
        didSet {
            text = bank?.displayName
            handleDidEndEditing(reconfigureStrategy: .always)
        }
    }
    
    private let errorMessage: String
    
    // MARK: - OptionSelectionViewConfiguring
    var icon: UIImage? { nil }
    
    var indicator: UIImage? {
        UIImage(named: "down", in: Bundle.paymentSheet)?
            .withTintColor(
                isEnabled ? .awxColor(.iconSecondary) : .awxColor(.iconDisabled),
                renderingMode: .alwaysOriginal
            )
    }
    
    var handleUserInteraction: () -> Void
    
    init(bank: AWXBank? = nil,
         language: AWXPaymentLanguage = .english,
         handleUserInteraction: @escaping () -> Void,
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.bank = bank
        self.errorMessage = NSLocalizedString("Please select a bank", bundle: .paymentSheet.language(language), comment: "user input validation - bank selection view error hint")
        self.handleUserInteraction = handleUserInteraction
        super.init(
            fieldName: AWXField.Name.bankName,
            title: NSLocalizedString("Bank", bundle: .paymentSheet.language(language), comment: "title for bank selection"),
            text: bank?.displayName,
            placeholder: NSLocalizedString("Select...", bundle: .paymentSheet.language(language), comment: "bank selection placeholder"),
            isRequired: true,
            reconfigureHandler: reconfigureHandler
        )
        inputValidator = BlockValidator { [weak self] _ in
            guard let self else { return }
            guard self.bank != nil else { throw self.errorMessage.asError() }
        }
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        assert(false, "should never triggered")
        return false
    }
}

class BankSelectionCellViewModel: BankSelectionViewModel, CellViewModelIdentifiable {
    let itemIdentifier: String
    init(bank: AWXBank? = nil,
         itemIdentifier: String,
         language: AWXPaymentLanguage = .english,
         handleUserInteraction: @escaping () -> Void,
         cellReconfigureHandler: @escaping CellReconfigureHandler) {
        self.itemIdentifier = itemIdentifier
        super.init(
            bank: bank,
            language: language,
            handleUserInteraction: handleUserInteraction,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
    }
}
