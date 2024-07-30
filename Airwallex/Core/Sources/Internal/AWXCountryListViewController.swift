//
//  AWXCountryListViewController.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc public protocol AWXCountryListViewControllerDelegate {
    @objc optional func countryListViewController(_ controller: AWXCountryListViewController, didSelect country: AWXCountry)
}

@objcMembers
@objc
public class AWXCountryListViewController: UIViewController {
    
    public weak var delegate: AWXCountryListViewControllerDelegate?
    
    public lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    public lazy var table: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CountryCell")
        return tv
    }()
    
    public var countries = AWXCountry.allCountries()
    public var matchedCountries = AWXCountry.allCountries()
    public var currentCountry: AWXCountry?
    
    
    public override func viewDidLoad() {
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", comment: "Close"), style: .plain, target: self, action: #selector(close))
        
        view.addSubview(searchBar)
        view.addSubview(table)
        
        let views = ["searchBar": searchBar, "tableView": table]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[searchBar]|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar][tableView]-|", metrics: nil, views: views))
    }
    
}

extension AWXCountryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchedCountries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        let country = matchedCountries[indexPath.row]
        cell.textLabel?.text = country.countryName
        if let currentCountry = currentCountry, currentCountry.countryName == country.countryName {
            let imageView = UIImageView(image: UIImage(named: "tick",in: Bundle.resource()))
            cell.accessoryView = imageView
        } else {
            cell.accessoryView = nil
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentCountry = matchedCountries[indexPath.row]
        if let currentCountry = currentCountry {
            delegate?.countryListViewController?(self, didSelect: currentCountry)
        }
    }
}

extension AWXCountryListViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            matchedCountries = countries.filter() { $0.countryName.contains(searchText)
            }
        } else {
            matchedCountries = countries
        }
        table.reloadData()
    }
}
