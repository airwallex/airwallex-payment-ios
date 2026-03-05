//
//  UIIntegrationDemoViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import UIKit

class UIIntegrationDemoViewController: IntegrationDemoListViewController {

    // MARK: - Abstract Property Overrides

    override var pageTitle: String {
        "Integrate with Airwallex UI"
    }

    override var actionViewModels: [ActionViewModel] {
        [
            ActionViewModel(
                title: "Launch default payments list",
                action: { [weak self] in
                    self?.launchDefaultPaymentsList(launchStyle: .push)
                }
            ),
            ActionViewModel(
                title: "Launch default payments list (dialog)",
                action: { [weak self] in
                    self?.launchDefaultPaymentsList(launchStyle: .present)
                }
            ),
            ActionViewModel(
                title: "Launch custom payments list",
                action: { [weak self] in
                    self?.launchCustomPaymentsList()
                }
            ),
            ActionViewModel(
                title: "Launch card payment",
                action: { [weak self] in
                    self?.launchCardPayment(launchStyle: .push)
                }
            ),
            ActionViewModel(
                title: "Launch card payment (dialog)",
                action: { [weak self] in
                    self?.launchCardPayment(launchStyle: .present)
                }
            ),
            ActionViewModel(
                title: "Embedded element - standard",
                action: { [weak self] in
                    self?.launchEmbeddedElement(
                        elementType: .standard,
                        showsApplePayAsPrimaryButton: true
                    )
                }
            ),
            ActionViewModel(
                title: "Embedded element - standard2",
                action: { [weak self] in
                    self?.launchEmbeddedElement(
                        elementType: .standard,
                        showsApplePayAsPrimaryButton: false
                    )
                }
            ),
            ActionViewModel(
                title: "Embedded element - addCard",
                action: { [weak self] in
                    self?.launchEmbeddedElement(
                        elementType: .addCard,
                        showsApplePayAsPrimaryButton: true
                    )
                }
            ),
            ActionViewModel(
                title: "Launch shipping address (dialog)",
                action: { [weak self] in
                    self?.launchShippingAddressDialog()
                }
            ),
        ]
    }
}

// MARK: - UI Integration Actions

private extension UIIntegrationDemoViewController {

    func launchDefaultPaymentsList(launchStyle: AWXUIContext.LaunchStyle) {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                AWXUIContext.launchPayment(
                    from: self,
                    session: session,
                    launchStyle: launchStyle,
                    layout: ExamplesKeys.paymentLayout
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }

    func launchCustomPaymentsList() {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                //  custom payment methods by an array of payment method name
                AWXUIContext.launchPayment(
                    from: self,
                    session: session,
                    filterBy: [AWXApplePayKey, AWXCardKey],
                    layout: ExamplesKeys.paymentLayout
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }

    func launchCardPayment(launchStyle: AWXUIContext.LaunchStyle) {
        Task {
            startLoading()
            do {
                let session = try await createPaymentSession()
                AWXUIContext.launchCardPayment(
                    from: self,
                    session: session,
                    supportedBrands: AWXCardBrand.allAvailable,
                    launchStyle: launchStyle
                )
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopLoading()
        }
    }

    func launchShippingAddressDialog() {
        let controller = AWXShippingViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.shipping = shippingAddress
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.present(nav, animated: true)
    }

    func launchEmbeddedElement(elementType: AWXPaymentElement.ElementType,
                               showsApplePayAsPrimaryButton: Bool) {
        let controller = EmbeddedIntegrationDemoViewController(
            elementType: elementType,
            showsApplePayAsPrimaryButton: showsApplePayAsPrimaryButton
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}
