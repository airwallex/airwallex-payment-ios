//
//  SettingsViewController+UITableViewDataSource.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 14/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit

extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Required", comment: "")
        case 1:
            return NSLocalizedString("Configuration", comment: "")
        default:
            preconditionFailure("Unexpected section title requested")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 7
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // environment
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Environment", comment: ""),
                    detail: viewModel.environment.title
                )
                
                return cell
            case 1:
                // API Token
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("API Key", comment: ""),
                    detail: viewModel.apiKey ?? ""
                )
                
                return cell
            case 2:
                // Client ID
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Client ID", comment: ""),
                    detail: viewModel.clientID ?? ""
                )
                
                return cell
            case 3:
                // return URL
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Return URL", comment: ""),
                    detail: viewModel.returnURL ?? ""
                )
                
                return cell
            default:
                preconditionFailure("Unknown table view row.")
            }
        case 1:
            switch indexPath.row {
            case 0:
                // checkout mode
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Checkout Mode", comment: ""),
                    detail: viewModel.checkoutMode.title
                )
                
                return cell
            case 1:
                // next trigger by
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Next trigger by", comment: ""),
                    detail: viewModel.nextTriggerBy.title
                )
                
                return cell
            case 2:
                // autocapture
                let cell: SwitchCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Autocapture", comment: ""),
                    isOn: viewModel.isAutocaptureEnabled
                ) { [weak viewModel] isOn in
                    guard let viewModel else { return }
                    viewModel.isAutocaptureEnabled = isOn
                }

                return cell
            case 3:
                // requires CVC
                let cell: SwitchCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Requires CVC", comment: ""),
                    isOn: viewModel.isRequiresCVCEnabled
                ) { [weak viewModel] isOn in
                    guard let viewModel else { return }
                    viewModel.isRequiresCVCEnabled = isOn
                }

                return cell
            case 4:
                // amount
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Amount", comment: ""),
                    detail: String(describing: viewModel.amount)
                )
                
                return cell
            case 5:
                // currency
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Currency", comment: ""),
                    detail: viewModel.currency
                )
                
                return cell
            case 6:
                // country code
                let cell: TitleSubtitleCellView = dequeueCell(at: indexPath, in: tableView)
                
                cell.populate(
                    title: NSLocalizedString("Country Code", comment: ""),
                    detail: viewModel.countryCode
                )
                
                return cell
            default:
                preconditionFailure("Unknown table view row.")
            }
        default:
            preconditionFailure("Unknown table view section.")
        }
    }

}
