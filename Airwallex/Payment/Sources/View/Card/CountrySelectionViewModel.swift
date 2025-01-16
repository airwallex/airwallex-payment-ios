//
//  CountrySelectionViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/8.
//  Copyright © 2025 Airwallex. All rights reserved.
//

class CountrySelectionViewModel: OptionSelectionViewConfiguring {
    var country: AWXCountry? {
        didSet {
            handleDidEndEditing()
        }
    }
    
    init(isEnabled: Bool = true,
         country: AWXCountry? = nil,
         handleUserInteraction: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.country = country
        self.handleUserInteraction = handleUserInteraction
        // don't give a error hint before user editing
        self.errorHint = nil
    }
    
    //  OptionSelectionViewConfiguring
    var fieldName: String = "country"
    
    var isRequired: Bool = true
    
    var title: String? = nil
    
    var hideErrorHintLabel = true
    
    var icon: UIImage? {
        guard let country else { return nil }
        return UIImage(named: country.countryCode, in: Bundle.resource())
    }
    
    var indicator: UIImage? {
        UIImage(named: "down", in: Bundle.resource())?
            .withTintColor(
                isEnabled ? .awxIconSecondary : .awxIconDisabled,
                renderingMode: .alwaysOriginal
            )
    }
    
    var text: String? {
        country?.countryName
    }
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil
    }
    
    var errorHint: String? = nil
    
    var textFieldType: AWXTextFieldType? = .country
    
    var placeholder: String? = NSLocalizedString("Select..", bundle: .payment, comment: "country selection view placeholder")
    
    var returnKeyType: UIReturnKeyType? = nil
    
    var returnActionHandler: ((BaseTextField) -> Void)? = nil
    
    func handleTextDidUpdate(textField: BaseTextField, to userInput: String) {
        assert(false, "should never triggered")
    }
    
    func handleDidEndEditing() {
        errorHint = (country != nil) ? nil : NSLocalizedString("Please enter your country", bundle: .payment, comment: "country selection view error hint")
    }
    
    var isEnabled: Bool
    
    var handleUserInteraction: () -> Void
    
}
