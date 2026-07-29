//
//  GetPaymentConsentsViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

class GetPaymentConsentsViewController: UITableViewController {
    private enum Row: Hashable {
        case consent(String)
        case details(String)
        case pay(String)

        var consentID: String {
            switch self {
            case let .consent(id), let .details(id), let .pay(id):
                return id
            }
        }
    }

    private lazy var dataSource = UITableViewDiffableDataSource<String, Row>(tableView: tableView) { [weak self] tableView, indexPath, row in
        guard let self,
              let consent = self.consent(withID: row.consentID) else {
            return UITableViewCell()
        }
        switch row {
        case .consent:
            return self.consentCell(for: consent, tableView: tableView, indexPath: indexPath)
        case .details:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.detailsReuseIdentifier, for: indexPath)
            cell.textLabel?.text = "View consent details"
            cell.textLabel?.textColor = .awxColor(.textPrimary)
            cell.imageView?.image = nil
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
            return cell
        case .pay:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.payReuseIdentifier, for: indexPath)
            guard let payCell = cell as? PayConsentCell else {
                return cell
            }
            payCell.configure { [weak self] in
                self?.pay(with: consent)
            }
            return payCell
        }
    }
    
    private func image(for brand: AWXBrandType) -> UIImage? {
        var imageName: String?
        switch brand {
        case .visa:
            imageName = "visa"
        case .amex:
            imageName = "amex"
        case .mastercard:
            imageName = "mastercard"
        case .unionPay:
            imageName = "unionpay"
        case .JCB:
            imageName = "jcb"
        case .dinersClub:
            imageName = "diners"
        case .discover:
            imageName = "discover"
        default:
            imageName = nil
        }
        guard let imageName else { return nil }
        return UIImage(named: imageName)
    }
    
    private lazy var storeAPIClient = Airwallex.apiClient
    private lazy var awxClient = AWXAPIClient(configuration: .shared())
    private var paymentIntent: AWXPaymentIntent?
    private var handler: PaymentSessionHandler?

    private lazy var items = [AWXPaymentConsent]()
    private var expandedConsentIDs = Set<String>()

    private let consentReuseIdentifier = "consentReuseIdentifier"
    private let detailsReuseIdentifier = "detailsReuseIdentifier"
    private let payReuseIdentifier = "payReuseIdentifier"
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(title: "Get saved card methods")
        view.setup(viewModel)
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBackButton()
        
        view.backgroundColor = .awxColor(.backgroundPrimary)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshControlTriggered), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: consentReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: detailsReuseIdentifier)
        tableView.register(PayConsentCell.self, forCellReuseIdentifier: payReuseIdentifier)
        
        tableView.addSubview(activityIndicator)
        tableView.separatorStyle = .none

        let tableHeaderView = UIView()
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableHeaderView.addSubview(topView)
        tableView.tableHeaderView = tableHeaderView
        
        let constraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            tableHeaderView.heightAnchor.constraint(equalToConstant: 64),
            topView.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 8),
            topView.leadingAnchor.constraint(equalTo: tableHeaderView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topView.trailingAnchor.constraint(equalTo: tableHeaderView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ]
        NSLayoutConstraint.activate(constraints)
        
        activityIndicator.startAnimating()
        onRefreshControlTriggered()
    }
    
    @objc func onRefreshControlTriggered() {
        Task {
            do {
                let response = try await requestCardConsents()
                guard !response.items.isEmpty else {
                    throw NSError.airwallexError(localizedMessage: "No consents found")
                }
                items = response.items.filter { $0.paymentMethod?.type == AWXCardKey }
                expandedConsentIDs.removeAll()
                performUpdates()
            } catch {
                showAlert(message: error.localizedDescription)
            }
            refreshControl?.endRefreshing()
            activityIndicator.stopAnimating()
        }
    }
    
    private func requestCardConsents() async throws -> AWXGetPaymentConsentsResponse {
        
        guard let customerId = ExamplesKeys.customerId else {
            throw NSError.airwallexError(localizedMessage: "Customer ID is required")
        }
        
        _ = try await ensurePaymentIntent()
        
        let request = AWXGetPaymentConsentsRequest()
        request.customerId = customerId
        request.status = "VERIFIED"
        request.nextTriggeredBy = FormatNextTriggerByType(AirwallexNextTriggerByType.customerType)
        request.pageNum = 0
        request.pageSize = 1000
        return try await awxClient.send(request) as! AWXGetPaymentConsentsResponse
    }
    
    private func performUpdates(reconfiguring consentID: String? = nil) {
        var snapshot = NSDiffableDataSourceSnapshot<String, Row>()
        items.forEach { consent in
            let id = consent.id
            snapshot.appendSections([id])
            snapshot.appendItems([.consent(id)], toSection: id)
            if expandedConsentIDs.contains(id) {
                snapshot.appendItems([.details(id), .pay(id)], toSection: id)
            }
        }
        if let consentID {
            let row = Row.consent(consentID)
            if #available(iOS 15.0, *) {
                snapshot.reconfigureItems([row])
            } else {
                snapshot.reloadItems([row])
            }
        }
        dataSource.apply(snapshot)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = dataSource.itemIdentifier(for: indexPath),
              let consent = consent(withID: row.consentID) else {
            return
        }
        switch row {
        case .consent:
            if expandedConsentIDs.contains(consent.id) {
                expandedConsentIDs.remove(consent.id)
            } else {
                expandedConsentIDs.insert(consent.id)
            }
            performUpdates(reconfiguring: consent.id)
        case .details:
            showDetails(for: consent)
        case .pay:
            pay(with: consent)
        }
    }

    private func consent(withID id: String) -> AWXPaymentConsent? {
        items.first { $0.id == id }
    }

    private func consentCell(
        for consent: AWXPaymentConsent,
        tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: consentReuseIdentifier, for: indexPath)
        guard let card = consent.paymentMethod?.card,
              let brand = card.brand else {
            assertionFailure("Invalid card consent")
            return cell
        }
        cell.textLabel?.textColor = .awxColor(.textPrimary)
        cell.textLabel?.text = "\(brand.capitalized) •••• \(card.last4 ?? "")"
        if let cardBrand = AWXCardValidator.shared().brand(forCardName: brand) {
            cell.imageView?.image = image(for: cardBrand.type)
        } else {
            cell.imageView?.image = nil
        }
        let chevronName = expandedConsentIDs.contains(consent.id) ? "chevron.up" : "chevron.down"
        let icon = UIImage(systemName: chevronName)?
            .withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
        let chevron = UIImageView(image: icon)
        cell.accessoryType = .none
        cell.accessoryView = chevron
        cell.selectionStyle = .none
        return cell
    }

    private func showDetails(for consent: AWXPaymentConsent) {
        guard let card = consent.paymentMethod?.card,
              let brand = card.brand else {
            assertionFailure("Invalid card consent")
            return
        }
        let viewController = TextContentViewController(
            infoTitle: "\(brand.capitalized) •••• \(card.last4 ?? "")",
            content: descriptionForConsent(consent)
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func ensurePaymentIntent() async throws -> AWXPaymentIntent {
        if let paymentIntent {
            AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
            return paymentIntent
        }
        let intent = try await storeAPIClient.createPaymentIntent()
        paymentIntent = intent
        AWXAPIClientConfiguration.shared().clientSecret = intent.clientSecret
        return intent
    }

    private func pay(with consent: AWXPaymentConsent) {
        Task {
            do {
                let paymentIntent = try await ensurePaymentIntent()
                let session = Session(paymentIntent: paymentIntent, countryCode: ExamplesKeys.countryCode)
                let handler = PaymentSessionHandler(session: session, viewController: self)
                self.handler = handler
                handler.startConsentPayment(withId: consent.id, requiresCVC: true)
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func descriptionForConsent(_ consent: AWXPaymentConsent) -> String {
        var result = "AWXPaymentConsent:\n"
        result += "- ID: \(consent.id)\n"
        result += "- Request ID: \(consent.requestId)\n"
        result += "- Customer ID: \(consent.customerId)\n"
        result += "- Status: \(consent.status)\n"
        result += "- Payment Method: \(consent.paymentMethod?.type ?? "None")\n"
        result += "- Next Triggered By: \(consent.nextTriggeredBy)\n"
        result += "- Merchant Trigger Reason: \(consent.merchantTriggerReason)\n"
        result += "- Requires CVC: \(consent.requiresCVC ? "Yes" : "No")\n"
        result += "- Created At: \(consent.createdAt)\n"
        result += "- Updated At: \(consent.updatedAt)\n"
        result += "- Client Secret: \(consent.clientSecret)\n"
        return result
    }
    
}

extension GetPaymentConsentsViewController: AWXPaymentResultDelegate {

    func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        switch status {
        case .success:
            paymentIntent = nil
            AWXAPIClientConfiguration.shared().clientSecret = nil
            showAlert(message: "Your payment has been charged", title: "Payment successful")
        case .inProgress:
            showAlert(message: "Your payment is still in progress", title: "Payment in progress")
        case .failure:
            showAlert(message: error?.localizedDescription ?? "There was an error while processing your payment. Please try again.", title: "Payment failed")
        case .cancel:
            showAlert(message: "Your payment has been cancelled", title: "Payment cancelled")
        }
    }
}

private final class PayConsentCell: UITableViewCell {
    private var action: (() -> Void)?

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pay with this consent", for: .normal)
        button.setTitleColor(.awxColor(.textInverse), for: .normal)
        button.titleLabel?.font = .awxFont(.headline1, weight: .bold)
        button.backgroundColor = .awxColor(.backgroundInteractive)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            button.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(action: @escaping () -> Void) {
        self.action = action
    }

    @objc private func buttonTapped() {
        action?()
    }
}
