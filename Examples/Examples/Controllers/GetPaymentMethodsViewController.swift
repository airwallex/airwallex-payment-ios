//
//  GetPaymentMethodsViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//


class GetPaymentMethodsViewController: UITableViewController {
    
    private let imageCache = NSCache<NSURL, UIImage>()
    private let sectionIdentifier = "section"
    private lazy var dataSource: UITableViewDiffableDataSource = UITableViewDiffableDataSource<String, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        guard let self else { return UITableViewCell() }
        let methodType = self.items[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
            configCell(cell, methodType: methodType)
            return cell
        }
        configCell(cell, methodType: methodType)
        return cell
    }
    
    private func configCell(_ cell: UITableViewCell, methodType: AWXPaymentMethodType) {
        cell.textLabel?.textColor = .awxTextPrimary
        cell.textLabel?.text = methodType.displayName
        cell.detailTextLabel?.text = methodType.transactionCurrencies.joined(separator: ", ")
        Task {
            let logoURL = methodType.resources.logoURL
            if let cachedImage = self.imageCache.object(forKey: logoURL as NSURL) {
                // Use the cached image
                await MainActor.run {
                    cell.imageView?.image = cachedImage
                    cell.setNeedsLayout()
                }
                return
            }
            
            // Fetch image data asynchronously
            do {
                let (data, _) = try await URLSession.shared.data(from: logoURL)
                if let image = UIImage(data: data) {
                    // Cache the image for reuse
                    self.imageCache.setObject(image, forKey: logoURL as NSURL)
                    
                    // Update the UI with the downloaded image
                    await MainActor.run {
                        cell.imageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
            } catch {
                print("Failed to fetch image: \(error.localizedDescription)")
            }
        }
    }
    
    private lazy var storeAPIClient = Airwallex.apiClient
    private lazy var awxClient = AWXAPIClient(configuration: AWXAPIClientConfiguration.shared())
    private lazy var items = [AWXPaymentMethodType]()
    
    private let reuseIdentifier = "reuseIdentifier"
    
    private lazy var topView: TopView = {
        let view = TopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = TopViewModel(title: NSLocalizedString("Get payment methods", comment: "DEMO"))
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
                let response = try await requestPaymentMethods()
                items = response.items
                performUpdates()
            } catch {
                showAlert(message: error.localizedDescription)
            }
            refreshControl?.endRefreshing()
            activityIndicator.stopAnimating()
        }
    }
    
    private func createPaymentIntentRequest() -> PaymentIntentRequest {
        PaymentIntentRequest(
            amount: Decimal(string: ExamplesKeys.amount)!,
            currency: ExamplesKeys.currency,
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
            returnUrl: ExamplesKeys.returnUrl,
            customerID: ExamplesKeys.customerId,
            paymentMethodOptions: nil,
            apiKey: ExamplesKeys.apiKey?.nilIfEmpty,
            clientID: ExamplesKeys.clientId?.nilIfEmpty
        )
    }
    
    private func requestPaymentMethods() async throws -> AWXGetPaymentMethodTypesResponse {
        
        // we need client secret to generate this API
        if AWXAPIClientConfiguration.shared().clientSecret == nil {
            let checkoutMode = ExamplesKeys.checkoutMode
            switch checkoutMode {
            case .oneOff, .recurringWithIntent:
                let intent = try await withCheckedThrowingContinuation { continuation in
                    storeAPIClient.createPaymentIntent(request: createPaymentIntentRequest()) { result in
                        continuation.resume(with: result)
                    }
                }
                AWXAPIClientConfiguration.shared().clientSecret = intent.clientSecret
            case .recurring:
                guard let customerId = ExamplesKeys.customerId else {
                    throw NSError.airwallexError(localizedMessage: "Customer ID is required")
                }
                let clientSecret = try await withCheckedThrowingContinuation { continuation in
                    storeAPIClient.generateClientSecret(
                        customerID: customerId,
                        apiKey:  ExamplesKeys.apiKey?.nilIfEmpty,
                        clientID: ExamplesKeys.clientId?.nilIfEmpty
                    ) { result in
                        continuation.resume(with: result)
                    }
                }
                AWXAPIClientConfiguration.shared().clientSecret = clientSecret
            }
        }
        
        let request = AWXGetPaymentMethodTypesRequest()
        request.transactionCurrency = ExamplesKeys.currency
        request.transactionMode = (ExamplesKeys.checkoutMode == .oneOff) ? "oneoff" : "recurring"
        request.countryCode = ExamplesKeys.countryCode
        request.pageNum = 0
        request.pageSize = 1000
        return try await awxClient.send(request) as! AWXGetPaymentMethodTypesResponse
    }
    
    private func performUpdates() {
        var snapshot = NSDiffableDataSourceSnapshot<String, String>()
        snapshot.appendSections([sectionIdentifier])
        snapshot.appendItems(self.items.map({ $0.name }))
        self.dataSource.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let methodType = items[indexPath.item]
        let viewController = TextContentViewController(
            infoTitle: methodType.displayName,
            content: descriptionForMethodType(methodType)
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func descriptionForMethodType(_ methodType: AWXPaymentMethodType) -> String {
        var output = ""
        output += "Payment Method Type:\n"
        output += "- Name: \(methodType.name)\n"
        output += "- Display Name: \(methodType.displayName)\n"
        output += "- Transaction Mode: \(methodType.transactionMode)\n"
        
        let flowsDescription = methodType.flows.isEmpty ? "N/A" : methodType.flows.joined(separator: ", ")
        output += "- Flows: \(flowsDescription)\n"
        
        let currenciesDescription = methodType.transactionCurrencies.isEmpty ? "N/A" : methodType.transactionCurrencies.joined(separator: ", ")
        output += "- Transaction Currencies: \(currenciesDescription)\n"
        
        output += "- Active: \(methodType.active)\n"
        output += "- Resources-logoURL: \(methodType.resources.logoURL)\n"
        output += "- Resources-hasSchema: \(methodType.resources.hasSchema)\n"
        output += "- Has Schema: \(methodType.hasSchema)\n"
        
        let cardSchemesDescription = methodType.cardSchemes.isEmpty ? "N/A" : methodType.cardSchemes.map { $0.name }.joined(separator: ", ")
        output += "- Supported Card Schemes: \(cardSchemesDescription)\n"
        
        return output
    }
    
}
