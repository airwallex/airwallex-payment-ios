//
//  PaymentConsentCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//


protocol PaymentConsentCellConfiguring {
    var image: UIImage? { get }
    var text: String { get }
    var buttonAction: () -> Void { get }
}

class PaymentConsentCell: UICollectionViewCell, ViewReusable, ViewConfigurable {
    
    private let logo: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .radius_m
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .awxBody
        view.textColor = .awxTextPrimary
        return view
    }()
    
    private let button: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .awxIconLink
        view.addTarget(self, action: #selector(onActionButtonTapped), for: .touchUpInside)
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.transform = CGAffineTransformMakeRotation(.pi/2)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private(set) var viewModel: PaymentConsentCellConfiguring?
    
    func setup(_ viewModel: any PaymentConsentCellConfiguring) {
        self.viewModel = viewModel
        logo.image = viewModel.image
        label.text = viewModel.text
    }
    
    // Action
    @objc func onActionButtonTapped() {
        viewModel?.buttonAction()
    }
}

private extension PaymentConsentCell {
    func setupViews() {
        contentView.addSubview(logo)
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        let constraints = [
            logo.widthAnchor.constraint(equalToConstant: 30),
            logo.heightAnchor.constraint(equalToConstant: 20),
            logo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .spacing_16),
            logo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: .spacing_16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor),
            
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.widthAnchor.constraint(equalTo: button.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

