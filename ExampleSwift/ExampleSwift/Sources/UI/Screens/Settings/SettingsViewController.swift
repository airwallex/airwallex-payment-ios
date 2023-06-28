//
//  SettingsViewController.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
 
    let viewModel = SettingsViewModel()
    
    func presentEditorActionSheet<T: Any>(
        actionSheetTitle: String,
        values: [T],
        indexPath: IndexPath,
        titleForValue: (T) -> String,
        onValueChanged: @escaping(T) -> Void
    ) {
        let alertController = UIAlertController(title: actionSheetTitle, message: "", preferredStyle: .actionSheet)
        
        for value in values {
            alertController.addAction(
                UIAlertAction(
                    title: titleForValue(value),
                    style: .default
                ) { [weak self] _ in
                    guard let self else { return }
                    onValueChanged(value)
                    self.tableView.reloadData()
                }
            )
        }
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        )
        
        present(alertController, animated: true)
    }
    
    func presentEditorAlert(
        title: String,
        currentValue: String?,
        indexPath: IndexPath,
        onValueChanged: @escaping (String?) -> Void
    ) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alertController.addTextField()
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        )
        
        guard let textField = alertController.textFields?.first else {
            return
        }
        
        textField.text = currentValue
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Submit", comment: ""), style: .default) { [weak self] _ in
                guard let self else { return }
                onValueChanged(textField.text)
                self.tableView.reloadData()
            }
        )
        present(alertController, animated: true)
    }
    
    @IBAction func didTapDoneButton(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapResetButton(sender: UIBarButtonItem) {
        viewModel.reset()
        tableView.reloadData()
    }
}
