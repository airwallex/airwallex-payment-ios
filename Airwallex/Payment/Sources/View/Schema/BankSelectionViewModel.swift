//
//  BankSelectionViewModel.swift
//  Core
//
//  Created by Weiping Li on 2025/1/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class BankSelectionViewModel: OptionSelectionViewConfiguring {
    
    var bank: AWXBank? {
        didSet {
            handleDidEndEditing()
        }
    }
    
    private let errorMessage = NSLocalizedString("Please select a bank", bundle: .payment, comment: "bank selection view error hint")
    
    init(bank: AWXBank? = nil,
         handleUserInteraction: @escaping () -> Void) {
        self.bank = bank
        self.handleUserInteraction = handleUserInteraction
    }
    
    func validate() throws {
        guard let bank else {
            throw errorMessage
        }
    }
    
    // MARK: - OptionSelectionViewConfiguring
    var fieldName: String = "bank"
    
    var isRequired: Bool = true
    
    var title: String? = NSLocalizedString("Bank", bundle: .payment, comment: "")
    
    var hideErrorHintLabel = false
    
    var icon: UIImage? { nil }
    
    var indicator: UIImage? {
        UIImage(named: "down", in: Bundle.resource())?
            .withTintColor(
                isEnabled ? .awxIconSecondary : .awxIconDisabled,
                renderingMode: .alwaysOriginal
            )
    }
    
    var handleUserInteraction: () -> Void
    
    var isEnabled: Bool = true
    
    var text: String? {
        bank?.displayName
    }
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil
    }
    
    var errorHint: String? = nil
    
    var textFieldType: AWXTextFieldType? = .default
    
    var placeholder: String? = NSLocalizedString("Select...", bundle: .payment, comment: "option selection view placeholder")
    
    var returnKeyType: UIReturnKeyType? = nil
    
    var returnActionHandler: ((BaseTextField) -> Void)? = nil
    
    func handleTextShouldChange(textField: BaseTextField, range: Range<String.Index>, replacementString string: String) -> Bool {
        assert(false, "should never triggered")
        return false
    }
    
    func handleDidEndEditing() {
        errorHint = (bank != nil) ? nil : errorMessage
    }
}
