//
//  AWXCountryListViewController.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc public protocol AWXCountryListViewControllerDelegate {
    @objc optional func countryListViewController(
        _ controller: AWXCountryListViewController, didSelect country: AWXCountry
    )
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

    var countries = AWXCountry.allCountries()
    var matchedCountries = AWXCountry.allCountries()
    public var currentCountry: AWXCountry?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func close() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

private extension AWXCountryListViewController {
    func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close"), style: .plain, target: self,
            action: #selector(close)
        )

        view.addSubview(searchBar)
        view.addSubview(table)

        let views = ["searchBar": searchBar, "tableView": table]
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[searchBar]|", metrics: nil, views: views
            ))
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[searchBar][tableView]-|", metrics: nil, views: views
            ))
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
        if let currentCountry = currentCountry, currentCountry.countryName == country.countryName {
            let imageView = UIImageView(image: UIImage(named: "tick", in: Bundle.resource()))
            cell.accessoryView = imageView
        } else {
            cell.accessoryView = nil
        }
        return cell
    }

    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCountry = matchedCountries[indexPath.row]
        if let currentCountry = currentCountry {
            delegate?.countryListViewController?(self, didSelect: currentCountry)
        }
    }
}

extension AWXCountryListViewController: UISearchBarDelegate {
    public func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            matchedCountries = countries.filter {
                $0.countryName.contains(searchText)
            }
        } else {
            matchedCountries = countries
        }
        table.reloadData()
    }
}