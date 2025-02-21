//
//  CheckBoxCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class CheckBoxCellViewModel {
    private(set) var isSelected: Bool
    
    let title: String?
    
    let boxInfo: String
    
    func toggleSelection() {
        isSelected.toggle()
        selectionDidChanged?(isSelected)
    }
    //  MARK: -
    private var selectionDidChanged: ((Bool) -> Void)?
    
    init(isSelected: Bool,
         title: String?,
         boxInfo: String = "",
         selectionDidChanged: ((Bool) -> Void)? = nil) {
        self.isSelected = isSelected
        self.title = title
        self.boxInfo = boxInfo
        self.selectionDidChanged = selectionDidChanged
    }
}
   

class CheckBoxCell: UICollectionViewCell, ViewConfigurable, ViewReusable {
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font  = .awxBody
        view.textColor = .awxTextPrimary
        return view
    }()
    
    private let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = .spacing_4
        view.alignment = .leading
        view.axis = .vertical
        return view
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Save my card for future payments", bundle: .payment, comment: ""), for: .normal)
        button.setTitleColor(.awxTextPrimary, for: .normal)
        button.titleLabel?.font = .awxHint
        
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let normalImage = UIImage(systemName: "square", withConfiguration: config)!
            .withTintColor(.awxBorderPerceivable, renderingMode: .alwaysOriginal)
        
        let selectedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: config)!
            .withTintColor(.awxBackgroundInteractive, renderingMode: .alwaysOriginal)
        
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.setImage(selectedImage, for: [.selected, .highlighted])
        
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(stack)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(button)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: CheckBoxCellViewModel?
    
    func setup(_ viewModel: CheckBoxCellViewModel) {
        self.viewModel = viewModel
        button.isSelected = viewModel.isSelected
        titleLabel.text = viewModel.title
        button.setTitle(viewModel.boxInfo, for: .normal)
        titleLabel.isHidden = (viewModel.title == nil || viewModel.title?.isEmpty == true)
    }
    
    @objc func buttonTapped() {
        button.isSelected = !button.isSelected
        viewModel?.toggleSelection()
    }
}
