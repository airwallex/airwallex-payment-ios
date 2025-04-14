//
//  HomePageTitleView.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class HomePageTitleView: UIView {
    private let logo: UIImageView = {
        let image = UIImage(named: "logo")
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let bar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxColor(.borderDecorative)
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Airwallex SDK"
        view.textColor = .awxColor(.textPrimary)
        view.font = .awxFont(.headline1, weight: .bold)
        view.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        return view
    }()
    
    private let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        view.alignment = .center
        return view
    }()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxColor(.borderDecorative)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stack)
        stack.addArrangedSubview(logo)
        stack.addArrangedSubview(bar)
        stack.addArrangedSubview(label)
        addSubview(bottomLine)
        
        let constraints = [
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            logo.widthAnchor.constraint(equalToConstant: 27),
            logo.heightAnchor.constraint(equalToConstant: 18),
            
            bar.heightAnchor.constraint(equalTo: logo.heightAnchor),
            bar.widthAnchor.constraint(equalToConstant: 1),
            
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
