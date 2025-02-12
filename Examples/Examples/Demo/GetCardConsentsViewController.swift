//
//  GetPaymentConsentsViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Airwallex

class GetPaymentConsentsViewController: UITableViewController {
    
    private let sectionIdentifier = "section"
    private lazy var dataSource: UITableViewDiffableDataSource = UITableViewDiffableDataSource<String, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        guard let self else { return UITableViewCell() }
        let consent = self.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let card = consent.paymentMethod?.card,
              let brand = card.brand else {
            assert(false, "invalid card consent")
            return cell
        }
        cell.textLabel?.textColor = .awxTextPrimary
        cell.textLabel?.text = "\(brand.capitalized) •••• \(card.last4 ?? "")"
        var image: UIImage? = nil
        if let cardBrand = AWXCardValidator.shared().brand(forCardName: brand) {
            image = self.image(for: cardBrand.type)
        }
        cell.imageView?.image = image
        return cell
    }
    
    private func image(for brand: AWXBrandType) -> UIImage? {
        var imageName: String? = nil
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
        return UIImage(named: imageName, in: Bundle.resource(), compatibleWith: nil)
    }
    
    private lazy var storeAPIClient = Airwallex.apiClient
    private lazy var awxClient = AWXAPIClient(configuration: AWXAPIClientConfiguration.shared())
    private lazy var items = [AWXPaymentConsent]()
    
    private let reuseIdentifier = "reuseIdentifier"
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(title: NSLocalizedString("Get saved card methods", comment: "DEMO"))
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
        
        view.backgroundColor = .awxBackgroundPrimary
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshControlTriggered), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.addSubview(activityIndicator)
        
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
                    throw "No data"
                }
                items = response.items.filter { $0.paymentMethod?.type == AWXCardKey }
                performUpdates()
            } catch {
                showAlert(message: error.localizedDescription)
            }
            refreshControl?.endRefreshing()
            activityIndicator.stopAnimating()
        }
    }
    
    private func createPaymentIntentRequest(customerID: String) -> PaymentIntentRequest {
        PaymentIntentRequest(
            amount: Decimal(string: AirwallexExamplesKeys.shared().amount)!,
            currency: AirwallexExamplesKeys.shared().currency,
            order: .init(
                products: [
                    .init(
                        type: "Free engraving",
                        code: "123",
                        name: "AirPods Pro",
                        sku: "piece",
                        quantity: 1,
                        unitPrice: 399,
                        desc: "Buy AirPods Pro, per month with trade-in",
                        url: "www.aircross.com"
                    ),
                ],
                shipping: .init(
                    firstName: "Jason",
                    lastName: "Wang",
                    phoneNumber: "13800000000",
                    address: .init(countryCode: "CN", state: "Shanghai", city: "Shanghai", street: "Pudong District", postcode: "100000")
                ),
                type: "physical_goods"
            ),
            metadata: ["id": 1],
            returnUrl: AirwallexExamplesKeys.shared().returnUrl,
            customerID: customerID,
            paymentMethodOptions: AirwallexExamplesKeys.shared().force3DS ? ["card": ["three_ds_action": "FORCE_3DS"]] : nil,
            apiKey: AirwallexExamplesKeys.shared().apiKey.nilIfEmpty,
            clientID: AirwallexExamplesKeys.shared().clientId.nilIfEmpty
        )
    }
    
    private func requestCardConsents() async throws -> AWXGetPaymentConsentsResponse {
        
        guard let customerId = AirwallexExamplesKeys.shared().customerId else {
            throw "Customer ID is required"
        }
        let checkoutMode = AirwallexExamplesKeys.shared().checkoutMode
        guard case .oneOffMode = checkoutMode else {
            throw "One-off payment is required"
        }
        // we need client secret to generate this API
        if AWXAPIClientConfiguration.shared().clientSecret == nil {
            let intent = try await withCheckedThrowingContinuation { continuation in
                storeAPIClient.createPaymentIntent(request: createPaymentIntentRequest(customerID: customerId)) { result in
                    continuation.resume(with: result)
                }
            }
            AWXAPIClientConfiguration.shared().clientSecret = intent.clientSecret
        }
        
        let request = AWXGetPaymentConsentsRequest()
        request.customerId = customerId
        request.status = "VERIFIED"
        request.nextTriggeredBy = FormatNextTriggerByType(AirwallexNextTriggerByType.customerType)
        request.pageNum = 0
        request.pageSize = 1000
        return try await awxClient.send(request) as! AWXGetPaymentConsentsResponse
    }
    
    private func performUpdates() {
        var snapshot = NSDiffableDataSourceSnapshot<String, String>()
        snapshot.appendSections([sectionIdentifier])
        snapshot.appendItems(self.items.map({ $0.id }))
        self.dataSource.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let card = items[indexPath.row].paymentMethod?.card,
              let brand = card.brand else {
            assert(false, "invalid card consent")
            return
        }
        let cardConsent = items[indexPath.item]
        let viewController = TextContentViewController(
            infoTitle: "\(brand.capitalized) •••• \(card.last4 ?? "")",
            content: descriptionForConsent(cardConsent)
        )
        navigationController?.pushViewController(viewController, animated: true)
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
