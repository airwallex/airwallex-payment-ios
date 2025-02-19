//
//  InformativeUserInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

protocol InfoCollectorTextFieldConfiguring: BaseTextFieldConfiguring {
    var isRequired: Bool { get }
    var title: String? { get }
    var hideErrorHintLabel: Bool { get }
    var fieldName: String { get }
}

class InfoCollectorTextField<T: InfoCollectorTextFieldConfiguring>: BaseTextField<T> {
    
    private let topLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextPrimary
        view.font = .awxBody
        return view
    }()
    
    private let hintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .awxTextError
        view.font = .awxHint
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
