//
//  InfoCollectorCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/8.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Combine

protocol InfoCollectorCellConfiguring: InfoCollectorTextFieldConfiguring {
    var triggerLayoutUpdate: () -> Void { get }
}

class InfoCollectorCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let field: InfoCollectorTextField = {
        let view = InfoCollectorTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(field)
        
        let constraints = [
            field.topAnchor.constraint(equalTo: contentView.topAnchor),
            field.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            field.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
        field.textDidEndEditingPublisher
            .sink { [weak self] textField in
                guard let self, let viewModel = self.viewModel else { return }
                // this will be called after error hint update
                viewModel.triggerLayoutUpdate()
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: (any InfoCollectorCellConfiguring)? {
        field.viewModel as? InfoCollectorCellConfiguring
    }
    
    func setup(_ viewModel: (any InfoCollectorCellConfiguring)) {
        field.setup(viewModel)
    }
}
