//
//  PaymentMethodCell.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

#if canImport(AirwallexCore)
import AirwallexCore
#endif

struct PaymentMethodCellViewModel: CellViewModelIdentifiable, CardBrandViewConfiguring {
    var itemIdentifier: String {
        return name
    }
    let name: String
    let displayName: String
    let imageURL: URL?
    var placeholder: UIImage? {
        switch name {
        case AWXCardKey:
            UIImage(named: "cardplaceholder", in: .paymentSheet)
        case AWXApplePayKey:
            UIImage(named: "applepaymark", in: .paymentSheet)
        default:
            nil
        }
    }
    let isSelected: Bool
    let imageLoader: ImageLoader
    let cardBrands: [AWXBrandType]
}

class PaymentMethodCell: UICollectionViewCell, ViewReusable, ViewConfigurable {

    private enum Layout {
        static let itemWidth: CGFloat = 92
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 8
        static let verticalPadding: CGFloat = topPadding + bottomPadding
        static let logoWidth: CGFloat = 30
        static let logoHeight: CGFloat = 20
        static let stackSpacing: CGFloat = 8
        static let maxLabelLines = 2
    }

    private let roundedBG: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .radius_l
        view.layer.borderWidth = 1
        view.layer.borderColor = .awxCGColor(.borderInteractive)
        view.backgroundColor = .awxColor(.backgroundPrimary)
        return view
    }()
    
    private let logo: UIImageView =  {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.awxFont(.caption2)
        view.textColor = .awxColor(.textLink)
        view.numberOfLines = Layout.maxLabelLines
        view.textAlignment = .center
        return view
    }()
    
    private let stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Layout.stackSpacing
        view.alignment = .center
        return view
    }()
    
    private(set) var viewModel: PaymentMethodCellViewModel?
    func setup(_ viewModel: PaymentMethodCellViewModel) {
        self.viewModel = viewModel
        if let URL = viewModel.imageURL {
            logo.loadImage(URL, imageLoader: viewModel.imageLoader)
        } else {
            logo.image = viewModel.placeholder
        }
        label.text = viewModel.displayName
        label.font = viewModel.isSelected ? .awxFont(.caption2, weight: .bold) : .awxFont(.caption2)
        label.textColor = viewModel.isSelected ? .awxColor(.textLink) : .awxColor(.textPrimary)
        roundedBG.layer.borderColor = viewModel.isSelected ? .awxCGColor(.borderInteractive) : .awxCGColor(.borderDecorative)
        roundedBG.backgroundColor = viewModel.isSelected ? .awxColor(.backgroundHighlight) : .awxColor(.backgroundPrimary)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            roundedBG.layer.borderColor = (viewModel?.isSelected ?? false) ? .awxCGColor(.borderInteractive) : .awxCGColor(.borderDecorative)
        }
    }
}

private extension PaymentMethodCell {
    func setupViews() {
        backgroundView = roundedBG
        
        contentView.addSubview(stack)
        stack.addArrangedSubview(logo)
        stack.addArrangedSubview(label)
        
        let constraints = [
            logo.widthAnchor.constraint(equalToConstant: Layout.logoWidth),
            logo.heightAnchor.constraint(equalToConstant: Layout.logoHeight),

            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.topPadding),
            stack.widthAnchor.constraint(
                lessThanOrEqualTo: contentView.widthAnchor,
                constant: -Layout.horizontalPadding
            ),
            stack.heightAnchor.constraint(
                lessThanOrEqualTo: contentView.heightAnchor,
                constant: -Layout.verticalPadding
            )
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension PaymentMethodCell {
    static let itemWidth = Layout.itemWidth

    private static let sizingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Layout.maxLabelLines
        label.textAlignment = .center
        label.font = UIFont.awxFont(.caption2)
        return label
    }()

    private static func estimatedLabelHeight(for text: String, width: CGFloat) -> CGFloat {
        sizingLabel.text = text
        return sizingLabel.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        ).height
    }

    static func estimatedItemHeight(
        displayNames: [String],
        itemWidth: CGFloat = Layout.itemWidth
    ) -> CGFloat {
        let labelWidth = itemWidth - Layout.horizontalPadding
        let font = UIFont.awxFont(.caption2)
        let labelHeight = displayNames
            .map { estimatedLabelHeight(for: $0, width: labelWidth) }
            .max() ?? font.lineHeight

        return ceil(
            Layout.topPadding
            + Layout.logoHeight
            + Layout.stackSpacing
            + labelHeight
            + Layout.bottomPadding
        )
    }
}
