//
//  HomeViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    private lazy var topView: HomePageTitleView = {
        let view = HomePageTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var integrateWithUIButton: UIButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Integrate with Airwallex UI", comment: "SDK DEMO"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(integrateWithUIButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var lowLevelAPIButton: UIButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Integrate with low-level API", comment: "SDK DEMO"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(lowLevelAPIButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var html5DemoButton: UIButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Integrate with HTML5 DEMO", comment: "SDK DEMO"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(html5DemoButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var WeChatDemoButton: UIButton = {
        let view = UIButton(style: .secondary, title: NSLocalizedString("Integrate with WeChat DEMO", comment: "SDK DEMO"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(weChatDemoButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
     
    override func viewDidLoad() {
        super.viewDidLoad()
       
        customizeNavigationBackIndicator()
        customizeNavigationBackButton()
        
        view.backgroundColor = .awxBackgroundPrimary
        view.addSubview(topView)
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        stack.addArrangedSubview(integrateWithUIButton)
        stack.addArrangedSubview(lowLevelAPIButton)
        stack.addArrangedSubview(html5DemoButton)
        stack.addArrangedSubview(WeChatDemoButton)
        
        let constraints = [
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor, constant: -32),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension HomeViewController {
    
    @objc func integrateWithUIButtonTapped() {
        navigationController?.pushViewController(IntegrationDemoListViewController(.UI), animated: true)
    }
    
    @objc func lowLevelAPIButtonTapped() {
        navigationController?.pushViewController(IntegrationDemoListViewController(.API), animated: true)
    }
    
    @objc func html5DemoButtonTapped() {
        navigationController?.pushViewController(H5DemoViewController(), animated: true)
    }
    
    @objc func weChatDemoButtonTapped() {
        navigationController?.pushViewController(WeChatDemoViewController(), animated: true)
    }
        
}
