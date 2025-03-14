//
//  CountrySelectionCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/12.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class CountrySelectionCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    private let view: OptionSelectionView = {
        let view = OptionSelectionView<CountrySelectionViewModel>()
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
    
    var viewModel: CountrySelectionCellViewModel? {
        view.viewModel as? CountrySelectionCellViewModel
    }
    
    func setup(_ viewModel: CountrySelectionCellViewModel) {
        view.setup(viewModel)
    }
}
