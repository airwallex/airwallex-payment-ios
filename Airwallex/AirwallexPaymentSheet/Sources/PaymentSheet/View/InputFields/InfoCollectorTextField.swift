//
//  InformativeUserInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

protocol InfoCollectorTextFieldConfiguring: BaseTextFieldConfiguring {
    /// Indicates whether this information is required.
    var isRequired: Bool { get }
    /// The title displayed above the text field.
    var title: String? { get }
    /// Error message for invalid input
    var errorHint: String? { get }
    /// Determines whether the error hint label, displayed below the text field, should be hidden.
    var hideErrorHintLabel: Bool { get }
    /// Useful when you need to compose parameters from the view model.
    var fieldName: String { get }
}

class InfoCollectorTextField<T: InfoCollectorTextFieldConfiguring>: BaseTextField<T> {
    
    private let topLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxColor(.textPrimary)
        view.font = .awxFont(.body2)
        return view
    }()
    
    private let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxColor(.textError)
        view.font = .awxFont(.caption2)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(_ viewModel: T) {
        super.setup(viewModel)
        
        topLabel.text = viewModel.title
        hintLabel.text = viewModel.errorHint
        
        topLabel.isHidden = viewModel.title == nil || viewModel.title?.isEmpty == true
        hintLabel.isHidden = viewModel.hideErrorHintLabel || viewModel.isValid || viewModel.errorHint == nil || viewModel.errorHint?.isEmpty == true
    }
    
    private func setupViews() {
        verticalStack.insertArrangedSubview(topLabel, at: 0)
        verticalStack.addArrangedSubview(hintLabel)
    }
}
