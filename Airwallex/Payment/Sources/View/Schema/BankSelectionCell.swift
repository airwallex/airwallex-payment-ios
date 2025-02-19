//
//  BankSelectionCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class BankSelectionCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    private let view: OptionSelectionView = {
        let view = OptionSelectionView<BankSelectionViewModel>()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(view)
        
        let constraints = [
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: BankSelectionViewModel? {
        view.viewModel as? BankSelectionViewModel
    }
    
    func setup(_ viewModel: BankSelectionViewModel) {
        view.setup(viewModel)
    }
}
