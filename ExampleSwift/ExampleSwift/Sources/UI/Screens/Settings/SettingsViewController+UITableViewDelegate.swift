//
//  SettingsViewController+UITableViewDelegate.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 14/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit
import Airwallex

extension SettingsViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // environment.
                let values = [
                    AirwallexSDKMode.demoMode,
                    AirwallexSDKMode.stagingMode,
                    AirwallexSDKMode.productionMode
                ]
                presentEditorActionSheet(
                    actionSheetTitle: NSLocalizedString("Environment", comment: ""),
                    values: values,
                    indexPath: indexPath,
                    titleForValue: { $0.title }
                ) { [weak viewModel] value in
                    guard let viewModel else { return }
                    viewModel.environment = value
                }
            case 1:
                // API Key
                presentEditorAlert(
                    title: NSLocalizedString("API Key", comment: ""),
                    currentValue: viewModel.apiKey,
                    indexPath: indexPath
                ) { [weak viewModel] value in
                    guard let viewModel else { return }
                    viewModel.apiKey = value
                }
            case 2:
                // Client ID
                presentEditorAlert(
                    title: NSLocalizedString("Client ID", comment: ""),
                    currentValue: viewModel.clientID,
                    indexPath: indexPath
                ) { [weak viewModel] value in
                    guard let viewModel else { return }
                    viewModel.clientID = value
                }
            case 3:
                // Return URL
                presentEditorAlert(
                    title: NSLocalizedString("Return URL", comment: ""),
                    currentValue: viewModel.returnURL,
                    indexPath: indexPath
                ) { [weak viewModel] value in
                    guard let viewModel else { return }
                    viewModel.returnURL = value
                }
            default:
                preconditionFailure("Unknown table view row.")
            }
        case 1:
            switch indexPath.row {
            case 0:
                // checkout mode
                let values = [
                    AirwallexCheckoutMode.oneOff,
                    AirwallexCheckoutMode.recurring,
                    AirwallexCheckoutMode.recurringWithIntent
                ]
                presentEditorActionSheet(
                    actionSheetTitle: NSLocalizedString("Checkout Mode", comment: ""),
                    values: values,
                    indexPath: indexPath,
                    titleForValue: { $0.title }
                ) { [weak viewModel] value in
                    guard let viewModel else { return }
                    viewModel.checkoutMode = value
                }
            case 1:
                // next trigger by
                let values = [
                    AirwallexNextTriggerByType.customerType,
                    AirwallexNextTriggerByType.merchantType
                ]
                presentEditorActionSheet(
                    actionSheetTitle: NSLocalizedString("Next Trigger By", comment: ""),
                    values: values,
                    indexPath: indexPath,
                    titleForValue: { $0.title }
                ) { [weak viewModel] value in
                    guard let viewModel else { return }
                    viewModel.nextTriggerBy = value
                }
            case 2:
                // autocapture
                // no op
                break
            case 3:
                // requires CVC
                // no op
                break
            case 4:
                // amount
                presentEditorAlert(
                    title: NSLocalizedString("Amount", comment: ""),
                    currentValue: String(describing: viewModel.amount),
                    indexPath: indexPath
                ) { [weak viewModel] value in
                    guard let viewModel = viewModel else { return }
                    viewModel.amount = Decimal(string: value ?? "") ?? .zero
                }
            case 5:
                // currency
                presentEditorAlert(
                    title: NSLocalizedString("Currency", comment: ""),
                    currentValue: String(describing: viewModel.currency),
                    indexPath: indexPath
                ) { [weak viewModel] value in
                    guard let viewModel = viewModel else { return }
                    viewModel.currency = value ?? ""
                }
            case 6:
                // country code
                presentEditorAlert(
                    title: NSLocalizedString("Country Code", comment: ""),
                    currentValue: String(describing: viewModel.countryCode),
                    indexPath: indexPath
                ) { [weak viewModel] value in
                    guard let viewModel = viewModel else { return }
                    viewModel.countryCode = value ?? ""
                }
            default:
                break
            }
        default:
            preconditionFailure("Unknown table view section.")
        }
    }
}
