//
//  CardNumberInputView.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine

protocol CardNumberInputViewConfiguring: ErrorHintableTextFieldConfiguring {
    var supportedBrands: [AWXBrandType] { get }
    var currentBrand: AWXBrandType { get }
}

class CardNumberInputView: UIView, ViewConfigurable {
    
    let userInputTextField: BasicUserInputView = {
        let view = BasicUserInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textField.update(for: .cardNumber)
        return view
    }()
    
    let logoStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = .spacing_4
        for _ in 0..<4 {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            stack.addArrangedSubview(imageView)
            
            imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        return stack
    }()
    
    weak var nextInputView: UIResponder? {
        get {
            userInputTextField.nextInputView
        }
        set {
            userInputTextField.nextInputView = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(userInputTextField)
        userInputTextField.stack.addArrangedSubview(logoStack)
        userInputTextField.textField.delegate = self
        
        let constraints = [
            userInputTextField.topAnchor.constraint(equalTo: topAnchor),
            userInputTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            userInputTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            userInputTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    private(set) var viewModel: (any CardNumberInputViewConfiguring)?
    
    func setup(_ viewModel: CardNumberInputViewConfiguring) {
        self.viewModel = viewModel
        userInputTextField.setup(viewModel)
        if viewModel.currentBrand != .unknown {
            updateLogos(brands: [viewModel.currentBrand])
        } else {
            updateLogos(brands: viewModel.supportedBrands)
        }
    }
    
    private var timer: Timer?
    private var counter = 1
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setupTimer()
    }
    
    func updateLogos(brands: [AWXBrandType]) {
        for (index, imageView) in logoStack.arrangedSubviews.enumerated() {
            guard let imageView = imageView as? UIImageView  else {
                imageView.isHidden = true
                continue
            }
                
            if index < brands.count {
                imageView.image = UIImage.image(for: brands[index])
                imageView.isHidden = false
            } else {
                imageView.isHidden = true
            }
        }
        
        setupTimer()
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupTimer() {
        invalidateTimer()
        guard let viewModel, viewModel.currentBrand == .unknown, window != nil else { return }
        let brands = viewModel.supportedBrands[(logoStack.arrangedSubviews.count-1)...]
        guard brands.count > 1 else { return }
            
        timer = Timer.scheduledTimer(
            withTimeInterval: 3,
            repeats: true,
            block: { [weak self] timer in
                guard let self else { return }
                guard let imageView = self.logoStack.arrangedSubviews.last as? UIImageView else {
                    self.invalidateTimer()
                    return
                }
                self.counter += 1
                let index = self.counter % brands.count
                let brand = brands[brands.startIndex + index]
                
                let transition = CATransition()
                transition.type = .fade
                imageView.layer.add(transition, forKey: nil)
                imageView.image = UIImage.image(for: brand)
            }
        )
    }
}

extension CardNumberInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        if let range = Range(range, in: currentText) {
            let text = currentText.replacingCharacters(in: range, with: string)
            guard let viewModel else { return false }
            viewModel.update(for: text)
            setup(viewModel)
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userInputTextField.textFieldShouldReturn(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userInputTextField.textFieldDidEndEditing(textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        userInputTextField.textFieldDidBeginEditing(textField)
    }
}
