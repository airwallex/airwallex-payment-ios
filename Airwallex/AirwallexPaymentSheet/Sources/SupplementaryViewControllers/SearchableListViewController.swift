//
//  SearchableListViewController.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import UIKit

protocol SearchableListItem {
    /// Stable identifier used to mark the currently-selected row.
    var id: String { get }
    var displayText: String { get }
    var searchableText: String { get }
    var leadingImage: UIImage? { get }
}

extension SearchableListItem {
    var leadingImage: UIImage? { nil }
}

class SearchableListViewController<Item: SearchableListItem>: UITableViewController, UISearchResultsUpdating {

    var items: [Item] = [] {
        didSet {
            filteredItems = items
            tableView.reloadData()
        }
    }
    var selectedItem: Item?
    var onSelect: ((Item) -> Void)?

    private var filteredItems: [Item] = []
    private let reuseIdentifier = "SearchableListCell"

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = NSLocalizedString(
            "Search",
            bundle: .paymentSheet,
            comment: "search placeholder in searchable list"
        )
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

    @objc private func close() {
        dismiss(animated: true)
    }

    private func filterItems(for searchText: String) {
        if searchText.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { item in
                item.searchableText.localizedCaseInsensitiveContains(searchText)
            }
        }
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let item = filteredItems[indexPath.row]

        cell.textLabel?.text = item.displayText
        cell.textLabel?.font = .awxFont(.body1)
        cell.textLabel?.textColor = .awxColor(.textPrimary)
        cell.backgroundColor = .awxColor(.backgroundPrimary)

        cell.imageView?.image = item.leadingImage

        if let selectedItem, selectedItem.id == item.id {
            let checkmark = UIImage(systemName: "checkmark")?
                .withTintColor(.awxColor(.iconLink), renderingMode: .alwaysOriginal)
            cell.accessoryView = UIImageView(image: checkmark)
        } else {
            cell.accessoryView = nil
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredItems[indexPath.row]
        selectedItem = item
        // Deactivate the search controller first — otherwise the host's `dismiss(animated:)`
        // call tears down the search controller alone and leaves this controller on screen,
        // requiring a second tap.
        if searchController.isActive {
            searchController.isActive = false
        }
        onSelect?(item)
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterItems(for: searchText)
    }
}
