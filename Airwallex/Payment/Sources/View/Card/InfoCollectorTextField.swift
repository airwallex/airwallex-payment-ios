//
//  InformativeUserInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

protocol InfoCollectorTextFieldConfiguring: ErrorHintableTextFieldConfiguring {
    var title: String? { get }
}

class InfoCollectorTextField: BaseTextField {
    
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
    
    override func setup(_ viewModel: any BaseTextFieldConfiguring) {
        super.setup(viewModel)
        guard let viewModel = viewModel as? InfoCollectorTextFieldConfiguring else {
            assert(false, "invalid view model")
            return
        }
        topLabel.text = viewModel.title
        hintLabel.text = viewModel.errorHint
    }
    
    private func setupViews() {
        verticalStack.insertArrangedSubview(topLabel, at: 0)
        verticalStack.addArrangedSubview(hintLabel)
    }
}
