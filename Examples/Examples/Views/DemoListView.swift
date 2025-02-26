//
//  DemoListView.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/13.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class DemoListView: UIView {
    private(set) lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var optionView: ConfigActionView = {
        let view = ConfigActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    private lazy var topStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        view.axis = .vertical
        return view
    }()
    
    private(set) lazy var bottomStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        view.axis = .vertical
        return view
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxColor(.borderDecorative)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        backgroundColor = .awxColor(.backgroundPrimary)
        addSubview(scrollView)
        scrollView.addSubview(topStack)
        do {
            topStack.addArrangedSubview(topView)
            topStack.setCustomSpacing(24, after: topView)
            topStack.addArrangedSubview(optionView)
        }
        
        scrollView.addSubview(separator)
        scrollView.addSubview(bottomStack)
        
        let heightRef = UIView()
        heightRef.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(heightRef)
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            topStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6),
            topStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            topStack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            separator.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            bottomStack.topAnchor.constraint(greaterThanOrEqualTo: topStack.bottomAnchor, constant: 64),
            bottomStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomStack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            
            heightRef.widthAnchor.constraint(equalToConstant: 10),
            heightRef.topAnchor.constraint(equalTo: scrollView.topAnchor),
            heightRef.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            heightRef.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            heightRef.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
