//
//  CardNumberTextField.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine

protocol CardNumberTextFieldConfiguring: BaseTextFieldConfiguring {
    var supportedBrands: [AWXBrandType] { get }
    var currentBrand: AWXBrandType { get }
}

class CardNumberTextField: BaseTextField {
    
    private let logoStack: UIStackView = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        horizontalStack.addArrangedSubview(logoStack)
        horizontalStack.addSpacer(.spacing_16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(_ viewModel: any BaseTextFieldConfiguring) {
        super.setup(viewModel)
        guard let viewModel = viewModel as? CardNumberTextFieldConfiguring else {
            assert(false, "invalid view model type")
            return
        }
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
    
    deinit {
        invalidateTimer()
    }
}

private extension CardNumberTextField {
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
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func setupTimer() {
        invalidateTimer()
        guard let viewModel = viewModel as? CardNumberTextFieldConfiguring, viewModel.currentBrand == .unknown, window != nil else { return }
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
