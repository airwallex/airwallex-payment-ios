//
//  CountrySelectionViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/8.
//  Copyright © 2025 Airwallex. All rights reserved.
//

class CountrySelectionViewModel: InfoCollectorTextFieldViewModel, OptionSelectionViewConfiguring {
    var country: AWXCountry? {
        didSet {
            text = country?.countryName
            handleDidEndEditing()
        }
    }
    
    var icon: UIImage? {
        guard let country else { return nil }
        return UIImage(named: country.countryCode, in: Bundle.resource())
    }
    
    var indicator: UIImage? {
        UIImage(named: "down", in: Bundle.resource())?
            .withTintColor(
                isEnabled ? .awxColor(.iconSecondary) : .awxColor(.iconDisabled),
                renderingMode: .alwaysOriginal
            )
    }
    
    var handleUserInteraction: () -> Void
    
    init(isEnabled: Bool = true,
         country: AWXCountry? = nil,
         handleUserInteraction: @escaping () -> Void,
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.country = country
        self.handleUserInteraction = handleUserInteraction
        super.init(
            fieldName: "country",
            isRequired: true,
            isEnabled: isEnabled,
            hideErrorHintLabel: true,
            text: country?.countryName,
            placeholder: NSLocalizedString("Select..", bundle: .payment, comment: "country selection view placeholder"),
            reconfigureHandler: reconfigureHandler
        )
        inputValidator = BlockValidator { [weak self] _ in
            guard let self else { return }
            guard self.country != nil else {
                throw NSLocalizedString(
                    "Please enter your country",
                    bundle: .payment,
                    comment: "country selection view error hint"
                ).asError()
            }
        }
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        assert(false, "should never trigger")
        return false
    }
}
