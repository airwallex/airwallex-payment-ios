//
//  SubdivisionSelectionViewModel.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

class SubdivisionSelectionViewModel: InfoCollectorTextFieldViewModel, OptionSelectionViewConfiguring {

    var options: [SubdivisionOption]

    var selection: SubdivisionOption? {
        didSet {
            text = selection?.label
            handleDidEndEditing(reconfigureStrategy: .always)
        }
    }

    var icon: UIImage? { nil }

    var indicator: UIImage? {
        UIImage(named: "down", in: .paymentSheet)?
            .withTintColor(
                isEnabled ? .awxColor(.iconSecondary) : .awxColor(.iconDisabled),
                renderingMode: .alwaysOriginal
            )
    }

    var handleUserInteraction: () -> Void

    init(options: [SubdivisionOption],
         selection: SubdivisionOption?,
         placeholder: String?,
         fieldName: String = "state",
         isEnabled: Bool = true,
         hideErrorHintLabel: Bool = true,
         handleUserInteraction: @escaping () -> Void,
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.options = options
        self.selection = selection
        self.handleUserInteraction = handleUserInteraction
        super.init(
            fieldName: fieldName,
            textFieldType: .state,
            text: selection?.label,
            placeholder: placeholder,
            isRequired: true,
            isEnabled: isEnabled,
            hideErrorHintLabel: hideErrorHintLabel,
            reconfigureHandler: reconfigureHandler
        )
        inputValidator = BlockValidator { [weak self] _ in
            guard let self else { return }
            guard self.selection != nil else {
                throw NSLocalizedString(
                    "Invalid state",
                    bundle: .paymentSheet,
                    comment: "subdivision selection view error hint"
                ).asError()
            }
        }
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        assert(false, "should never trigger")
        return false
    }
}
