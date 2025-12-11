//
//  UIViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

extension UIViewController {
    
    func customizeNavigationBackIndicator() {
        let offset: CGFloat = 6
        let image = UIImage(named: "arrow_left")!
        var size = image.size
        size.width += offset
        let renderer = UIGraphicsImageRenderer(size: size)
        let newImage = renderer.image { context in
            image.draw(at: .init(x: offset, y: 0))
        }.withTintColor(.awxColor(.textPrimary), renderingMode: .alwaysOriginal)
        navigationController?.navigationBar.backIndicatorImage = newImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = newImage
    }
    
    func customizeNavigationBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }
    
    func showAlert(message: String?,
                   title: String? = nil,
                   buttonTitle: String = "OK",
                   action: (() -> Void)? = nil) {
        guard title != nil || message != nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: buttonTitle, style: .cancel) { _ in
            action?()
        }
        alert.addAction(closeAction)
        present(alert, animated: true)
    }
    
    func showOptions<T>(_ options: [T], sender: UIView?, completion: @escaping (Int, T) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for (index, option) in options.enumerated() {
            let action = UIAlertAction(
                title: String(describing: option),
                style: .default,
                handler: { _ in
                    completion(index, option)
                }
            )
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
}

class LoadingView: UIView {
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            label.isHidden = newValue == nil
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8

        addSubview(stackView)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
        ])
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}

extension UIViewController {
    private static let tagForLoadingView = 2025

    func startLoading(text: String? = nil) {
        view.isUserInteractionEnabled = false

        // Check if loading view already exists
        if let loadingView = view.viewWithTag(Self.tagForLoadingView) as? LoadingView {
            view.bringSubviewToFront(loadingView)
            loadingView.text = text
            loadingView.startAnimating()
            return
        }

        // Create new loading view
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.tag = Self.tagForLoadingView
        loadingView.text = text
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            loadingView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])

        loadingView.startAnimating()
    }

    func stopLoading() {
        view.isUserInteractionEnabled = true
        if let loadingView = view.viewWithTag(Self.tagForLoadingView) as? LoadingView {
            loadingView.stopAnimating()
            loadingView.removeFromSuperview()
        }
    }
}
