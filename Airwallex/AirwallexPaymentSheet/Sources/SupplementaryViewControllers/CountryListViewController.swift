//
//  CountryListViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/23.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

protocol CountryListViewControllerDelegate: AnyObject {
    func countryListViewController(_ controller: CountryListViewController, didSelect country: AWXCountry)
}

class CountryListViewController: UITableViewController {

    weak var delegate: CountryListViewControllerDelegate?
    var selectedCountry: AWXCountry?

    private var countries: [AWXCountry] = []
    private var filteredCountries: [AWXCountry] = []
    private let reuseIdentifier = "CountryCell"

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = NSLocalizedString(
            "Search",
            bundle: .paymentSheet,
            comment: "search placeholder in country list"
        )
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCountries()
    }

    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let closeTitle = NSLocalizedString(
            "Close",
            bundle: .paymentSheet,
            comment: "close button on navigation bar"
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: closeTitle,
            style: .plain,
            target: self,
            action: #selector(close)
        )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .awxColor(.backgroundPrimary)
        tableView.separatorColor = .awxColor(.borderDecorative)
    }

    private func loadCountries() {
        countries = AWXCountry.allCountries()
        filteredCountries = countries
        tableView.reloadData()
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    private func filterCountries(for searchText: String) {
        if searchText.isEmpty {
            filteredCountries = countries
        } else {
            filteredCountries = countries.filter { country in
                country.countryName.localizedCaseInsensitiveContains(searchText)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension CountryListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCountries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let country = filteredCountries[indexPath.row]

        cell.textLabel?.text = country.countryName
        cell.textLabel?.font = .awxFont(.body1)
        cell.textLabel?.textColor = .awxColor(.textPrimary)
        cell.backgroundColor = .awxColor(.backgroundPrimary)

        // Flag image
        cell.imageView?.image = UIImage(named: country.countryCode, in: .paymentSheet, compatibleWith: nil)

        // Checkmark for selected country
        if selectedCountry?.countryCode == country.countryCode {
            let checkmark = UIImage(systemName: "checkmark")?
                .withTintColor(.awxColor(.iconLink), renderingMode: .alwaysOriginal)
            cell.accessoryView = UIImageView(image: checkmark)
        } else {
            cell.accessoryView = nil
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = filteredCountries[indexPath.row]
        selectedCountry = country
        delegate?.countryListViewController(self, didSelect: country)
    }
}

// MARK: - UISearchResultsUpdating

extension CountryListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterCountries(for: searchText)
    }
}
