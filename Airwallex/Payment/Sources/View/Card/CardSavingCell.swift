//
//  CardSavingCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/27.
//  Copyright © 2024 Airwallex. All rights reserved.
//

protocol CardSavingCellConfiguring {
    var shouldSaveCard: Bool { get set }
    
    var toggleSelection: () -> Void { get }
}
    

class CardSavingCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Save my card for future payments", bundle: .payment, comment: ""), for: .normal)
        button.setTitleColor(.awxTextPrimary, for: .normal)
        button.titleLabel?.font = .awxHint
        
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let normalImage = UIImage(systemName: "square", withConfiguration: config)!
            .withTintColor(.awxBorderPerceivable)
        
        let selectedImage = UIImage(systemName: "checkmark.square.fill", withConfiguration: config)!
            .withTintColor(.awxBackgroundInteractive)
        
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
        
        contentView.addSubview(button)
        
        let constraints = [
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var viewModel: (any CardSavingCellConfiguring)?
    
    func setup(_ viewModel: any CardSavingCellConfiguring) {
        self.viewModel = viewModel
        button.isSelected = viewModel.shouldSaveCard
    }
    
    
    @objc func buttonTapped() {
        button.isSelected = !button.isSelected
        viewModel?.shouldSaveCard = button.isSelected
        viewModel?.toggleSelection()
    }
}
