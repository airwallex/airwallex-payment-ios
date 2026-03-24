//
//  BankListViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/3.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

// MARK: - BankCell

/// A table view cell matching the AWXOptionView layout:
/// left-aligned label, right-aligned logo, rounded highlight on tap.
private class BankCell: UITableViewCell {

    static let reuseIdentifier = "BankCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .awxFont(.body2)
        label.textColor = .awxColor(.textPrimary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = highlighted ? .awxColor(.backgroundField): .awxColor(.backgroundPrimary)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(bank: AWXBank, imageLoader: ImageLoader) {
        nameLabel.text = bank.displayName
        if let logoURL = bank.resources.logoURL {
            logoView.loadImage(logoURL, imageLoader: imageLoader)
        } else {
            logoView.image = nil
        }
    }

    private func setupViews() {
        backgroundColor = .awxColor(.backgroundPrimary)
        selectionStyle = .none

        contentView.addSubview(nameLabel)
        contentView.addSubview(logoView)

        nameLabel.setContentCompressionResistancePriority(.defaultHigh - 50, for: .horizontal)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            logoView.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 16),
            logoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            logoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoView.heightAnchor.constraint(equalToConstant: 20),
            logoView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        logoView.image = nil
    }
}

// MARK: - BankListViewController

class BankListViewController: UIViewController {

    private let banks: [AWXBank]
    private let imageLoader: ImageLoader
    private let onBankSelected: (AWXBank) -> Void

    // Retained to keep the transitioning delegate alive during presentation
    private var bottomSheetTransitioningDelegate: BottomSheetTransitioningDelegate?

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.register(BankCell.self, forCellReuseIdentifier: BankCell.reuseIdentifier)
        table.backgroundColor = .awxColor(.backgroundPrimary)
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        table.translatesAutoresizingMaskIntoConstraints = false
        table.tableHeaderView = makeHeaderView()
        return table
    }()

    init(banks: [AWXBank], imageLoader: ImageLoader, onBankSelected: @escaping (AWXBank) -> Void) {
        self.banks = banks
        self.imageLoader = imageLoader
        self.onBankSelected = onBankSelected
        super.init(nibName: nil, bundle: nil)

        let interactiveDismiss = BottomSheetInteractiveDismissTransition(
            presentedViewController: self,
            scrollView: tableView
        )
        bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
            interactiveDismiss: interactiveDismiss
        )
        modalPresentationStyle = .custom
        transitioningDelegate = bottomSheetTransitioningDelegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func makeHeaderView() -> UIView {
        let label = UILabel()
        label.text = NSLocalizedString(
            "Select your Bank",
            bundle: .paymentSheet,
            comment: "title of Bank Selection form"
        )
        label.font = .awxFont(.subtitle1, weight: .medium)
        label.textColor = .awxColor(.textPrimary)
        // tableHeaderView uses frame-based layout; position the label with insets
        let headerHeight: CGFloat = 56
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        label.frame = container.bounds.inset(by: UIEdgeInsets(top: 24, left: 24, bottom: 8, right: 24))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(label)
        return container
    }

    private func setupViews() {
        view.backgroundColor = .awxColor(.backgroundPrimary)

        view.addSubview(tableView)

        let headerHeight = tableView.tableHeaderView?.frame.height ?? 0
        let tableViewHeight = CGFloat(banks.count) * 56 + headerHeight
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight).priority(.required - 1),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource

extension BankListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        banks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BankCell.reuseIdentifier, for: indexPath)
        if let bankCell = cell as? BankCell {
            bankCell.configure(bank: banks[indexPath.row], imageLoader: imageLoader)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension BankListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bank = banks[indexPath.row]
        dismiss(animated: true) { [onBankSelected] in
            onBankSelected(bank)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
}
