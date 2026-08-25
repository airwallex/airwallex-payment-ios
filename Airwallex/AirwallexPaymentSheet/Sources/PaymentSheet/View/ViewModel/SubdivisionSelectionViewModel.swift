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
            text = Self.displayText(for: selection)
            handleDidEndEditing(reconfigureStrategy: .always)
        }
    }

    /// Wraps the selected option's label with a Left-to-Right Isolate (U+2066) so the
    /// underlying `UITextField` doesn't right-align bilingual sub_labels (e.g. AE's
    /// "أبو ظبي — Abu Dhabi"). UITextField resolves `textAlignment = .natural` against the
    /// bidi base direction (detected from the first strong char), while the matching
    /// `UITableViewCell.textLabel` in the picker resolves it against the interface
    /// direction — the LRI marker forces both to render with the same LTR-anchored layout.
    private static func displayText(for selection: SubdivisionOption?) -> String? {
        selection.map { "\u{2066}\($0.label)" }
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
         language: AWXPaymentLanguage = .english,
         handleUserInteraction: @escaping () -> Void,
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.options = options
        self.selection = selection
        self.handleUserInteraction = handleUserInteraction
        super.init(
            fieldName: fieldName,
            textFieldType: .state,
            text: Self.displayText(for: selection),
            placeholder: placeholder,
            isRequired: true,
            isEnabled: isEnabled,
            hideErrorHintLabel: hideErrorHintLabel,
            language: language,
            reconfigureHandler: reconfigureHandler
        )
        inputValidator = BlockValidator { [weak self] _ in
            guard let self else { return }
            guard self.selection != nil else {
                throw NSLocalizedString("Invalid state", bundle: .paymentSheet.language(language), comment: "subdivision selection view error hint").asError()
            }
        }
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        assert(false, "should never trigger")
        return false
    }
}
