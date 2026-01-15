//
//  OrderInfoView.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

class OrderInfoView: UIView {

    // MARK: - Properties

    private let products: [PhysicalProduct]
    private let shipping: AWXPlaceDetails?

    // MARK: - UI Components

    private lazy var containerStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 16
        return view
    }()

    private lazy var orderSummaryHeader: UILabel = {
        createSectionHeader("Order Summary")
    }()

    private lazy var totalRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill

        let totalLabel = UILabel()
        totalLabel.text = "Total"
        totalLabel.font = .awxFont(.headline1)
        totalLabel.textColor = .awxColor(.textPrimary)

        let total = products.reduce(Decimal(0)) { $0 + ($1.unitPrice ?? 0) * Decimal($1.quantity ?? 0) }
        let amountLabel = UILabel()
        amountLabel.text = "$\(total)"
        amountLabel.font = .awxFont(.headline1)
        amountLabel.textColor = .awxColor(.textPrimary)
        amountLabel.textAlignment = .right

        stack.addArrangedSubview(totalLabel)
        stack.addArrangedSubview(amountLabel)

        return stack
    }()

    private lazy var shippingHeader: UILabel = {
        createSectionHeader("Shipping Address")
    }()

    private lazy var shippingInfoView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        let nameLabel = UILabel()
        nameLabel.text = "\(shipping?.firstName ?? "") \(shipping?.lastName ?? "")"
        nameLabel.font = .awxFont(.body2)
        nameLabel.textColor = .awxColor(.textPrimary)

        let addressLabel = UILabel()
        let address = shipping?.address
        addressLabel.text = [address?.street, address?.city, address?.state, address?.postcode, address?.countryCode]
            .compactMap { $0 }
            .joined(separator: ", ")
        addressLabel.font = .awxFont(.body2)
        addressLabel.textColor = .awxColor(.textSecondary)
        addressLabel.numberOfLines = 0

        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(addressLabel)

        return stack
    }()

    // MARK: - Initializers

    init(products: [PhysicalProduct], shipping: AWXPlaceDetails? = nil) {
        self.products = products
        self.shipping = shipping
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.borderColor = .awxCGColor(.borderDecorative)
        }
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(containerStack)

        // Order summary section
        containerStack.addArrangedSubview(orderSummaryHeader)

        for product in products {
            let productRow = createProductRow(product)
            containerStack.addArrangedSubview(productRow)
        }

        containerStack.addArrangedSubview(totalRow)

        var constraints = [NSLayoutConstraint]()
        // Shipping section (optional)
        if shipping != nil {
            let separator = createSeparator()
            containerStack.addArrangedSubview(separator)
            containerStack.addArrangedSubview(shippingHeader)
            containerStack.setCustomSpacing(24, after: totalRow)
            containerStack.addArrangedSubview(shippingInfoView)
            
            constraints.append(separator.heightAnchor.constraint(equalToConstant: 1))
        }
        
        constraints += [
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Helpers

    private func createSectionHeader(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .awxFont(.headline1, weight: .bold)
        label.textColor = .awxColor(.textPrimary)
        return label
    }

    private func createProductRow(_ product: PhysicalProduct) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill

        let nameLabel = UILabel()
        let productName = product.name ?? "Item"
        let quantity = product.quantity ?? 1
        nameLabel.text = "\(productName) x\(quantity)"
        nameLabel.font = .awxFont(.body2)
        nameLabel.textColor = .awxColor(.textPrimary)

        let priceLabel = UILabel()
        let itemTotal = (product.unitPrice ?? 0) * Decimal(quantity)
        priceLabel.text = "$\(itemTotal)"
        priceLabel.font = .awxFont(.body2)
        priceLabel.textColor = .awxColor(.textPrimary)
        priceLabel.textAlignment = .right

        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(priceLabel)

        return stack
    }
    
    private func createSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxColor(.borderDecorative)
        return view
    }
}
