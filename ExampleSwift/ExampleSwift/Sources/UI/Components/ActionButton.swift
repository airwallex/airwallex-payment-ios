//
//  ActionButton.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 26/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit
import Airwallex

class ActionButton: UIButton {
    
    var isLoading = false {
        didSet {
            updateView()
        }
    }
    
    private var activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        activityIndicator.style = .medium
        
        updateColors()
        
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
       
        updateColors()
    }
    
    private func updateColors() {
        awx_setBackgroundColor(AWXTheme.shared().tintColor, for: .normal)
        setTitleColor(AWXTheme.shared().primaryButtonTextColor(), for: .normal)
    }
    
    func updateView() {
        if isLoading {
            activityIndicator.startAnimating()
            titleLabel?.alpha = 0
            imageView?.alpha = 0
            isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            titleLabel?.alpha = 1
            imageView?.alpha = 0
            isEnabled = true
        }
    }
}
