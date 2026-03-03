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

    private let order: PurchaseOrder
    private let amount: Decimal
    private let currency: String
    private let countryCode: String
    private var isExpanded = false

    // MARK: - UI Components

    private lazy var headerBar: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let storeStack = UIStackView()
        storeStack.translatesAutoresizingMaskIntoConstraints = false
        storeStack.axis = .horizontal
        storeStack.spacing = 6
        storeStack.alignment = .center

        let storeIcon = UIImageView()
        storeIcon.image = UIImage(systemName: "storefront.fill")
        storeIcon.tintColor = .awxColor(.textPrimary)
        storeIcon.contentMode = .scaleAspectFit
        storeIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        storeIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storeIcon.widthAnchor.constraint(equalToConstant: 18),
            storeIcon.heightAnchor.constraint(equalToConstant: 18),
        ])

        let storeLabel = UILabel()
        storeLabel.text = "Demo store"
        storeLabel.font = .awxFont(.caption1, weight: .medium)
        storeLabel.textColor = .awxColor(.textPrimary)

        storeStack.addArrangedSubview(storeIcon)
        storeStack.addArrangedSubview(storeLabel)

        let toggleStack = UIStackView()
        toggleStack.translatesAutoresizingMaskIntoConstraints = false
        toggleStack.axis = .horizontal
        toggleStack.spacing = 4
        toggleStack.alignment = .center

        let toggleLabel = UILabel()
        toggleLabel.text = "Order details"
        toggleLabel.font = .awxFont(.caption1, weight: .medium)
        toggleLabel.textColor = .awxColor(.textPrimary)

        let chevronView = UIImageView()
        chevronView.image = UIImage(systemName: "chevron.down")
        chevronView.tintColor = .awxColor(.textPrimary)
        chevronView.contentMode = .scaleAspectFit
        chevronView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevronView.widthAnchor.constraint(equalToConstant: 16),
            chevronView.heightAnchor.constraint(equalToConstant: 16),
        ])
        self.chevronView = chevronView

        toggleStack.addArrangedSubview(toggleLabel)
        toggleStack.addArrangedSubview(chevronView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpanded))
        toggleStack.addGestureRecognizer(tapGesture)
        toggleStack.isUserInteractionEnabled = true

        let bottomBorder = UIView()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.backgroundColor = .awxColor(.borderDecorative)

        container.addSubview(storeStack)
        container.addSubview(toggleStack)
        container.addSubview(bottomBorder)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 56),

            storeStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            storeStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            toggleStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            toggleStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            bottomBorder.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: 1),
        ])

        return container
    }()

    private weak var chevronView: UIImageView?

    private lazy var detailContainer: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.isHidden = true
        stack.backgroundColor = .awxColor(.backgroundSecondary)
        return stack
    }()

    private lazy var totalContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .awxColor(.backgroundSecondary)
        container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let totalLabel = UILabel()
        totalLabel.text = "Total to pay"
        totalLabel.font = .awxFont(.caption1)
        totalLabel.textColor = .awxColor(.textPrimary)
        totalLabel.translatesAutoresizingMaskIntoConstraints = false

        let amountLabel = UILabel()
        amountLabel.text = formatTotalAmount()
        amountLabel.font = .systemFont(ofSize: 24, weight: .bold)
        amountLabel.textColor = .awxColor(.textPrimary)
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(totalLabel)
        container.addSubview(amountLabel)

        let margins = container.layoutMarginsGuide
        NSLayoutConstraint.activate([
            totalLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            totalLabel.topAnchor.constraint(greaterThanOrEqualTo: margins.topAnchor),
            totalLabel.bottomAnchor.constraint(lessThanOrEqualTo: margins.bottomAnchor),

            amountLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            amountLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            amountLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: totalLabel.trailingAnchor, constant: 8),

            totalLabel.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
        ])

        return container
    }()

    // MARK: - Initializers

    init(order: PurchaseOrder, amount: Decimal, currency: String, countryCode: String) {
        self.order = order
        self.amount = amount
        self.currency = currency
        self.countryCode = countryCode
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .awxColor(.backgroundPrimary)

        let mainStack = UIStackView()
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        mainStack.addArrangedSubview(headerBar)
        mainStack.addArrangedSubview(detailContainer)
        mainStack.addArrangedSubview(totalContainer)

        setupDetailContent()
    }

    private func setupDetailContent() {
        // Order summary header
        let summaryHeader = UILabel()
        summaryHeader.text = "Order summary"
        summaryHeader.font = .systemFont(ofSize: 18, weight: .bold)
        summaryHeader.textColor = .awxColor(.textPrimary)
        detailContainer.addArrangedSubview(summaryHeader)

        // Product rows
        let products = order.products
        for product in products {
            let productRow = createProductRow(product)
            detailContainer.addArrangedSubview(productRow)
        }

        // Divider before fee/subtotal
        detailContainer.addArrangedSubview(createDivider())

        // Fee/Discount row (conditional)
        let productSum = products.reduce(Decimal(0)) { $0 + ($1.unitPrice ?? 0) * Decimal($1.quantity ?? 0) }
        let difference = amount - productSum

        if difference != 0 {
            let feeLabel = difference > 0 ? "Fee" : "Discount"
            let feeRow = createPricingRow(
                title: feeLabel,
                value: formatCurrencySymbol(difference),
                valueWeight: .regular
            )
            detailContainer.addArrangedSubview(feeRow)
        }

        // Subtotal row
        let subtotalRow = createPricingRow(
            title: "Subtotal",
            value: formatCurrencySymbol(amount),
            valueWeight: .medium
        )
        detailContainer.addArrangedSubview(subtotalRow)

        // Divider before total
        detailContainer.addArrangedSubview(createDivider())
    }

    // MARK: - Actions

    @objc private func toggleExpanded() {
        isExpanded.toggle()
        let chevron = isExpanded ? "chevron.up" : "chevron.down"
        chevronView?.image = UIImage(systemName: chevron)

        UIView.animate(withDuration: 0.3) {
            self.detailContainer.isHidden = !self.isExpanded
            self.detailContainer.alpha = self.isExpanded ? 1 : 0
            self.superview?.layoutIfNeeded()
        }
    }

    // MARK: - Helpers

    private func createProductRow(_ product: PhysicalProduct) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .center

        // Product icon
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "bag.fill")
        iconView.tintColor = .awxColor(.iconSecondary)
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 6
        iconView.clipsToBounds = true
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
        ])

        // Text content
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2

        let nameLabel = UILabel()
        nameLabel.text = product.name ?? "Item"
        nameLabel.font = .awxFont(.caption1)
        nameLabel.textColor = .awxColor(.textSecondary)

        let priceRow = UIStackView()
        priceRow.axis = .horizontal
        priceRow.distribution = .fill

        let unitPrice = product.unitPrice ?? 0
        let quantity = product.quantity ?? 1
        let priceLabel = UILabel()
        priceLabel.text = "\(formatCurrencySymbol(unitPrice)) \u{00D7} \(quantity)"
        priceLabel.font = .awxFont(.caption1)
        priceLabel.textColor = .awxColor(.textSecondary)

        let totalLabel = UILabel()
        let itemTotal = unitPrice * Decimal(quantity)
        totalLabel.text = formatCurrencySymbol(itemTotal)
        totalLabel.font = .awxFont(.caption1)
        totalLabel.textColor = .awxColor(.textPrimary)
        totalLabel.textAlignment = .right

        priceRow.addArrangedSubview(priceLabel)
        priceRow.addArrangedSubview(totalLabel)

        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(priceRow)

        container.addArrangedSubview(iconView)
        container.addArrangedSubview(textStack)

        return container
    }

    private func createPricingRow(title: String, value: String, valueWeight: UIFont.Weight) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .awxFont(.caption1)
        titleLabel.textColor = .awxColor(.textSecondary)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .awxFont(.caption1, weight: valueWeight)
        valueLabel.textColor = .awxColor(.textPrimary)
        valueLabel.textAlignment = .right

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)

        return stack
    }

    private func createDivider() -> UIView {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .awxColor(.borderDecorative)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    // MARK: - Formatting

    private func formatCurrencySymbol(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale(identifier: "en_\(countryCode)")
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private func formatTotalAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formattedNumber = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "\(formattedNumber) \(currency)"
    }
}
