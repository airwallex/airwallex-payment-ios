//
//  Untitled.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/8.
//  Copyright © 2025 Airwallex. All rights reserved.
//

protocol CountrySelectionViewConfiguring: BaseTextFieldConfiguring {
    
    var country: AWXCountry? { get set }
    
    var handleUserInteraction: () -> Void { get }
}

class CountrySelectionView: BaseTextField<CountrySelectionViewModel> {
    
    private let iconWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 28).isActive = true
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        view.layer.cornerRadius = .radius_s
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var indicator: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "down", in: Bundle.resource())?
            .withTintColor(.awxIconSecondary, renderingMode: .alwaysOriginal)
        return view
    }()
    
    private lazy var cover: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onUserTapped))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup(_ viewModel: CountrySelectionViewModel) {
        super.setup(viewModel)
        
        iconWrapper.isHidden = viewModel.country == nil
        if let country = viewModel.country {
            icon.image = UIImage(named: country.countryCode, in: Bundle.resource())
        }
        indicator.image = UIImage(named: "down", in: Bundle.resource())?
            .withTintColor(viewModel.isEnabled ? .awxIconSecondary : .awxIconDisabled, renderingMode: .alwaysOriginal)
    }
}

private extension CountrySelectionView {
    
    func setupViews() {
        iconWrapper.addSubview(icon)
        horizontalStack.insertSpacer(.spacing_12, at: 0)
        horizontalStack.insertArrangedSubview(iconWrapper, at: 1)
        var insets = textField.textInsets
        insets.left = 0
        insets.right = 0
        textField.textInsets = insets
        horizontalStack.addArrangedSubview(indicator)
        horizontalStack.addSpacer(.spacing_12)

        addSubview(cover)
        let constraints = [
            cover.topAnchor.constraint(equalTo: topAnchor),
            cover.leadingAnchor.constraint(equalTo: leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            icon.topAnchor.constraint(equalTo: iconWrapper.topAnchor),
            icon.leadingAnchor.constraint(equalTo: iconWrapper.leadingAnchor),
            icon.trailingAnchor.constraint(equalTo: iconWrapper.trailingAnchor, constant: -.spacing_8),
            icon.bottomAnchor.constraint(equalTo: iconWrapper.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func onUserTapped() {
        guard let viewModel = viewModel as? CountrySelectionViewConfiguring else {
            assert(false, "invalid view model")
            return
        }
        if viewModel.isEnabled == true {
            viewModel.handleUserInteraction()
        }
    }
}
