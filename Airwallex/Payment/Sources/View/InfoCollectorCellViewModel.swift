//
//  InfoCollectorCellViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Combine

class InfoCollectorCellViewModel<T: Hashable & Sendable>: InfoCollectorTextFieldViewModel, CellViewModelIdentifiable {
    
    /// This identifier is intended to work with CollectionViewManager
    var itemIdentifier: T
    
    init(itemIdentifier: T,
         fieldName: String = "",
         textFieldType: AWXTextFieldType = .default,
         title: String? = nil,
         text: String? = nil,
         attributedText: NSAttributedString? = nil,
         placeholder: String? = nil,
         errorHint: String? = nil,
         isRequired: Bool = true,
         isEnabled: Bool = true,
         isValid: Bool = true,
         hideErrorHintLabel: Bool = false,
         clearButtonMode: UITextField.ViewMode = .whileEditing,
         returnKeyType: UIReturnKeyType = .default,
         returnActionHandler: CellReturnActionHandler? = nil,
         customInputFormatter: UserInputFormatter? = nil,
         customInputValidator: UserInputValidator? = nil,
         editingEventObserver: UserEditingEventObserver? = nil,
         cellReconfigureHandler: @escaping CellReconfigureHandler) {
        self.itemIdentifier = itemIdentifier
        let fieldName = !fieldName.isEmpty ? fieldName : String(describing: itemIdentifier)
        super.init(
            fieldName: fieldName,
            textFieldType: textFieldType,
            title: title,
            text: text,
            attributedText: attributedText,
            placeholder: placeholder,
            errorHint: errorHint,
            isRequired: isRequired,
            isEnabled: isEnabled,
            isValid: isValid,
            hideErrorHintLabel: hideErrorHintLabel,
            clearButtonMode: clearButtonMode,
            returnKeyType: returnKeyType,
            customInputFormatter: customInputFormatter,
            customInputValidator: customInputValidator,
            editingEventObserver: editingEventObserver,
            reconfigureHandler: { cellReconfigureHandler(itemIdentifier, $1) }
        )
        self.returnActionHandler = { [weak self] responder in
            guard let self, let returnActionHandler else {
                return false
            }
            return returnActionHandler(responder, itemIdentifier)
        }
    }
}
