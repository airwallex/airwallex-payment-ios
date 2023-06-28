//
//  CartViewController.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import UIKit
import Airwallex

class CartViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private var customerIDLabel: UITextView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var submitButton: ActionButton!
    
    // MARK: - Properties
    
    let viewModel = CartViewModel()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSDK()
        
        updateCustomerIDLabel()
    }
    
    // MARK: - CartViewController
    
    private func setupSDK() {
        // Step 1: Set an environment mode to use
        let mode: AirwallexSDKMode = viewModel.environment
        Airwallex.setMode(mode)
        
        // You can choose to disable collecting Analytics data if desired.
        // Airwallex.disableAnalytics()
        
        // You can also customise the tint if desired.
        // AWXTheme.shared().tintColor = UIColor.systemPink
        
        // Step 2: See the logic in CartViewModel to see how to implement authentication,
        // creating customers, client secrets, payment intents and sessions.
    }
    
    @IBAction func didTapSubmitButton(sender: UIButton) {
        submitButton.isLoading = true
        
        Task { @MainActor in
            do {
                let session = try await viewModel.prepareForCheckOut()
                let context = AWXUIContext.shared()
                context.delegate = self
                context.session = session
                context.presentPaymentFlow(from: self)
                
                submitButton.isLoading = false
            } catch let error {
                submitButton.isLoading = false
                
                onErrorReceived(error)
            }
            
            updateCustomerIDLabel()
        }
    }
    
    private func updateCustomerIDLabel() {
        if let customerID = viewModel.customerID {
            self.customerIDLabel.text = NSLocalizedString("Customer ID: \(customerID)", comment: "")
        } else {
            self.customerIDLabel.text = nil
        }
    }
    
    private func onErrorReceived(_ error: Error) {
        switch error {
        case ExamplesError.paymentIntentError:
            showAlert(
                title: NSLocalizedString("Unable to create Payment Intent", comment: ""),
                message: NSLocalizedString("Please check the parameters and try again.", comment: "")
            )
        case ExamplesError.missingRequiredConfigurationError:
            showAlert(
                title: NSLocalizedString("Missing configuration", comment: ""),
                message: NSLocalizedString("Have you set your API Key and Client ID?", comment: "")
            )
        case ExamplesError.missingCustomerIDError:
            showAlert(
                title: NSLocalizedString("Missing Customer ID", comment: ""),
                message: NSLocalizedString("Please check the parameters and try again.", comment: "")
            )
        case ExamplesError.clientSecretError:
            showAlert(
                title: NSLocalizedString("Client Secret Not Generated", comment: ""),
                message: NSLocalizedString("Please check the parameters and try again.", comment: "")
            )
        case ExamplesError.apiError(let title, let message):
            showAlert(
                title: title,
                message: message
            )
        default:
            showAlert(
                title: NSLocalizedString("Something went wrong", comment: ""),
                message: NSLocalizedString("Please check the parameters and try again.", comment: "")
            )
        }
    }
    
    private func onPaymentFailed(error: Error?) {
        let title = NSLocalizedString("Payment Failed", comment: "")
        let message = error?.localizedDescription ?? NSLocalizedString("There was an error processing your payment. Please try again.", comment: "")
        showAlert(title: title, message: message)
    }
    
    private func onPaymentCanceled() {
        let title = NSLocalizedString("Payment Canceled", comment: "")
        let message = NSLocalizedString("Your payment has been canceled.", comment: "")
        showAlert(title: title, message: message)
    }
    
    private func onPaymentSucceeded() {
        let title = NSLocalizedString("Payment Succeeded", comment: "")
        let message = NSLocalizedString("Your payment succeeded.", comment: "")
        showAlert(title: title, message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .default
            )
        )
        
        present(alertController, animated: true)
    }
}

extension CartViewController: AWXPaymentResultDelegate {
    func paymentViewController(
        _ controller: UIViewController,
        didCompleteWith status: AirwallexPaymentStatus,
        error: Error?
    ) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            
            switch status {
            case .cancel:
                self.onPaymentCanceled()
            case .failure:
                self.onPaymentFailed(error: error)
            case .inProgress:
                // no op
                break
            case .success:
                self.onPaymentSucceeded()
            @unknown default:
                // no op
                break
            }
        }
    }
}
