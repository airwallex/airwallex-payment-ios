//
//  TextContentViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class TextContentViewController: UIViewController {

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.font = .awxFont(.body1)
        view.textColor = .awxTextPrimary
        view.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return view
    }()
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let infoTitle: String
    private let content: String
    
    init(infoTitle: String, content: String) {
        self.infoTitle = infoTitle
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .awxBackgroundPrimary
        view.addSubview(topView)
        view.addSubview(textView)
        let constraints = [
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
        topView.setup(TopViewModel(title: infoTitle))
        textView.text = content
    }
}
