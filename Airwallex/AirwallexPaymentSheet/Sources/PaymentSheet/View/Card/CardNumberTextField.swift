//
//  CardNumberTextField.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

class CardNumberTextField: BaseTextField<CardNumberTextFieldViewModel> {
    
    private let cardBrandView: CardBrandView = {
        let view = CardBrandView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        horizontalStack.addArrangedSubview(cardBrandView)
        horizontalStack.addSpacer(16)
        
        if #available(iOS 15.0, *) {
            let toolbar = UIToolbar()
            let captureAction = UIAction.captureTextFromCamera(responder: textField, identifier: nil)
            let scanButton = UIBarButtonItem(primaryAction: captureAction)
            toolbar.items = [scanButton]
            toolbar.sizeToFit()
            textField.inputAccessoryView = toolbar
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(_ viewModel: CardNumberTextFieldViewModel) {
        super.setup(viewModel)
        cardBrandView.setup(viewModel)
    }
}
