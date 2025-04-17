//
//  CardBrandView.swift
//  Payment
//
//  Created by Weiping Li on 2025/4/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

protocol CardBrandViewConfiguring {
    var cardBrands: [AWXBrandType] { get }
}

class CardBrandView: UIView, ViewConfigurable {
    
    private let logoStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
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
       
        addSubview(logoStack)
        
        let constraints = [
            logoStack.topAnchor.constraint(equalTo: topAnchor),
            logoStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            logoStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            logoStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: CardBrandViewConfiguring?
    
    func setup(_ viewModel: CardBrandViewConfiguring) {
        self.viewModel = viewModel
        updateLogos(brands: viewModel.cardBrands)
    }
    
    private var timer: Timer?
    private var counter = 1
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setupTimer()
    }
    
    deinit {
        invalidateTimer()
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
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func setupTimer() {
        invalidateTimer()
        guard let viewModel, !viewModel.cardBrands.isEmpty, window != nil else { return }
        guard viewModel.cardBrands.count > logoStack.arrangedSubviews.count else { return }
        let animatingBrands = viewModel.cardBrands[(logoStack.arrangedSubviews.count-1)...]
        //  animatingBrands.count > 1 means there are more brands than logo stack's arranged subview,
        //  we need to display them 1 by 1 at the last position of the logo stack
        guard animatingBrands.count > 1 else { return }
            
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
                let index = self.counter % animatingBrands.count
                let brand = animatingBrands[animatingBrands.startIndex + index]
                
                let transition = CATransition()
                transition.type = .fade
                imageView.layer.add(transition, forKey: nil)
                imageView.image = UIImage.image(for: brand)
            }
        )
    }
}
