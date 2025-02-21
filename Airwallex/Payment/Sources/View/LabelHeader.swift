//
//  LabelHeaderView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/11.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

class LabelHeader: UICollectionReusableView, ViewReusable {
    lazy var label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.boldSystemFont(ofSize: 20)
        view.text = NSLocalizedString("Payment Methods", bundle: .payment, comment: "title for payment sheet")
        view.textColor = AWXTheme.shared().primaryTextColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupViews() {
        addSubview(label)
        
        let constraints = [
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
