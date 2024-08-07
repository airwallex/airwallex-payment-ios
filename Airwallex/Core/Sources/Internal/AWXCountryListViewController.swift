//
//  AWXCountryListViewController.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc public protocol AWXCountryListViewControllerDelegate {
    @objc optional func countryListViewController(_ controller: AWXCountryListViewController,
                                                  didSelect country: AWXCountry)
}

@objcMembers
@objc
public class AWXCountryListViewController: UIViewController {
    public weak var delegate: AWXCountryListViewControllerDelegate?

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private lazy var table: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CountryCell")
        return tv
    }()

    private let allCountries = AWXCountry.allCountries()
    private var matchedCountries = AWXCountry.allCountries()
    public var currentCountry: AWXCountry?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

extension AWXCountryListViewController {
    private func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close"), style: .plain, target: self,
            action: #selector(close)
        )

        view.addSubview(searchBar)
        view.addSubview(table)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            table.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func close() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension AWXCountryListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return matchedCountries.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        let country = matchedCountries[indexPath.row]
        cell.textLabel?.text = country.countryName
        if let currentCountry, currentCountry.countryName == country.countryName {
            let imageView = UIImageView(image: UIImage(named: "tick", in: Bundle.resource()))
            cell.accessoryView = imageView
        } else {
            cell.accessoryView = nil
        }
        return cell
    }

    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCountry = matchedCountries[indexPath.row]
        if let currentCountry {
            delegate?.countryListViewController?(self, didSelect: currentCountry)
        }
    }
}

extension AWXCountryListViewController: UISearchBarDelegate {
    public func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            matchedCountries = allCountries.filter {
                $0.countryName.contains(searchText)
            }
        } else {
            matchedCountries = allCountries
        }
        table.reloadData()
    }
}
