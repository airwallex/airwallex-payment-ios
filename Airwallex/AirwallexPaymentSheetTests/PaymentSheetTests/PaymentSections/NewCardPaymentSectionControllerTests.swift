//
//  NewCardPaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class NewCardPaymentSectionControllerTests: BasePaymentSectionControllerTests {
    
    var mockCard: AWXCard!
    
    override func setUp() {
        super.setUp()
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        methodType.cardSchemes = AWXCardScheme.allAvailable
        mockMethodProvider.methods = [methodType]
        mockMethodProvider.selectedMethod = methodType
        
        guard let data = Bundle.dataOfFile("payment_consents"),
              let response = AWXGetPaymentConsentsResponse.parse(data) as? AWXGetPaymentConsentsResponse,
              response.items.count == 2 else {
            XCTFail()
            return
        }
        mockMethodProvider.consents = response.items
        mockSectionProvider.preferConsentPayment = false
        // setup valid card info
        mockCard = AWXCard(
            name: "John Appleseed",
            cardNumber: "4111111111111111",
            expiryMonth: "12",
            expiryYear: "2099",
            cvc: "333"
        )
    }
    
    private func getCardSectionController() -> NewCardPaymentSectionController? {
        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let cardSectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            return nil
        }
        return cardSectionController
    }
    
    func testInit() {
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentNew)
        XCTAssertFalse(sectionController.items.isEmpty)
        XCTAssertTrue(sectionController.items.contains(.consentToggle))
        mockMethodProvider.consents = []
        mockManager.performUpdates()
        XCTAssertFalse(sectionController.items.contains(.consentToggle))
    }
    
    func testInitWithAccordion() {
        mockSectionProvider.layout = .accordion
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentNew)
        mockViewController.view.layoutIfNeeded()
        XCTAssertNotNil(sectionController.context.cellForItem(sectionController.sectionItem(.accordionKey)))
    }
    
    func testRequiredBillingFields_None() {
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(.cardholderName))
        XCTAssertFalse(sectionController.items.contains(.billingFieldEmail))
        XCTAssertFalse(sectionController.items.contains(.billingFieldPhone))
        XCTAssertFalse(sectionController.items.contains(.billingFieldAddress))
        XCTAssertFalse(sectionController.items.contains(.billingFieldCountryCode))
    }
    
    func testRequiredBillingFields_AddressAndCountryCode() {
        mockMethodProvider.session.requiredBillingContactFields = [.name, .address, .countryCode]
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertTrue(sectionController.items.contains(.cardholderName))
        XCTAssertFalse(sectionController.items.contains(.billingFieldEmail))
        XCTAssertFalse(sectionController.items.contains(.billingFieldPhone))
        XCTAssertTrue(sectionController.items.contains(.billingFieldAddress))
        XCTAssertFalse(sectionController.items.contains(.billingFieldCountryCode))
    }
    
    func testRequiredBillingFields_EmailAndPhone() {
        mockMethodProvider.session.requiredBillingContactFields = [.phone, .email, .countryCode]
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(.cardholderName))
        XCTAssertTrue(sectionController.items.contains(.billingFieldEmail))
        XCTAssertTrue(sectionController.items.contains(.billingFieldPhone))
        XCTAssertFalse(sectionController.items.contains(.billingFieldAddress))
        XCTAssertTrue(sectionController.items.contains(.billingFieldCountryCode))
    }
    
    func testSaveCardToggle_OneOff() {
        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.customerId = "customer_id"
        session.requiredBillingContactFields = []
        mockMethodProvider.session = session
        
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertTrue(sectionController.items.contains(.saveCardToggle))

        guard let cell = sectionController.context.cellForItem(sectionController.sectionItem(.saveCardToggle)) as? CheckBoxCell,
              let isSelected = cell.viewModel?.isSelected else {
            XCTFail()
            return
        }
        XCTAssertEqual(isSelected, session.autoSaveCardForFuturePayments)
    }
    
    func testSaveCardToggle_OneOff_noCustomerId() {
        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.requiredBillingContactFields = []
        mockMethodProvider.session = session
    
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(.saveCardToggle))
        XCTAssertNil(sectionController.context.cellForItem(sectionController.sectionItem(.saveCardToggle)))
    }
    
    func testSaveCardToggle_OneOff_disableAutoSave() {
        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.customerId = "customer_id"
        session.requiredBillingContactFields = []
        session.autoSaveCardForFuturePayments = false
        mockMethodProvider.session = session
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertTrue(sectionController.items.contains(.saveCardToggle))
    
        guard let cell = sectionController.context.cellForItem(sectionController.sectionItem(.saveCardToggle)) as? CheckBoxCell,
              let isSelected = cell.viewModel?.isSelected else {
            XCTFail()
            return
        }
        XCTAssertEqual(isSelected, session.autoSaveCardForFuturePayments)
    }
    
    func testSaveCardToggle_RecurringSession() {
        let session = AWXRecurringSession()
        session.setCustomerId("customer_id")
        mockMethodProvider.session = session
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(.saveCardToggle))
        XCTAssertNil(sectionController.context.cellForItem(sectionController.sectionItem(.saveCardToggle)))
    }
    
    func testSaveCardToggle_RecurringWithIntentSession() {
        let session = AWXRecurringWithIntentSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.id = "intent_id"
        session.paymentIntent?.clientSecret = "client_secret"
        session.paymentIntent?.customerId = "customer_id"
        mockMethodProvider.session = session
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(.saveCardToggle))
        XCTAssertNil(sectionController.context.cellForItem(sectionController.sectionItem(.saveCardToggle)))
    }
    
    func testSaveCardToggle_toggleUnionPay() {
        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.customerId = "customer_id"
        session.requiredBillingContactFields = []
        mockMethodProvider.session = session
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertTrue(sectionController.items.contains(.saveCardToggle))
        guard let toggleCell = sectionController.context.cellForItem(sectionController.sectionItem(.saveCardToggle)) as? CheckBoxCell else {
            XCTFail()
            return
        }
        XCTAssert(toggleCell.viewModel?.isSelected == true)
        toggleCell.viewModel?.toggleSelection()
        XCTAssert(toggleCell.viewModel?.isSelected == false)
        toggleCell.viewModel?.toggleSelection()

        guard let cardInfoCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardInfo)) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }
        let textField = UITextField()
        _ = cardInfoCell.viewModel?.cardNumberConfigurer.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "62"
        )
        (cardInfoCell.allFields.first as? CardNumberTextField)?.editingDidEnd(textField)
        XCTAssertTrue(sectionController.items.contains(.unionPayWarning))
    }
    
    func testReuseShippingInfo_All() {
        mockMethodProvider.session.requiredBillingContactFields = [.address, .email, .name, .phone, ]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let addressCell = sectionController.context.cellForItem(sectionController.sectionItem(.billingFieldAddress)) as? BillingInfoCell else {
            XCTFail()
            return
        }
        XCTAssert(addressCell.viewModel?.canReusePrefilledAddress == true)
        XCTAssert(addressCell.viewModel?.shouldReusePrefilledAddress == true)
        XCTAssertEqual(addressCell.viewModel?.countryConfigurer.country?.countryCode, mockShippingInfo.address?.countryCode)
        XCTAssertEqual(addressCell.viewModel?.stateConfigurer.text, mockShippingInfo.address?.state)
        XCTAssertEqual(addressCell.viewModel?.cityConfigurer.text, mockShippingInfo.address?.city)
        XCTAssertEqual(addressCell.viewModel?.zipConfigurer.text, mockShippingInfo.address?.postcode)
        
        guard let emailCell = sectionController.context.cellForItem(sectionController.sectionItem(.billingFieldEmail)) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(emailCell.viewModel?.text, mockShippingInfo.email)
        
        guard let nameCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardholderName)) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(nameCell.viewModel?.text, mockShippingInfo.fullName)
        
        guard let phoneCell = sectionController.context.cellForItem(sectionController.sectionItem(.billingFieldPhone)) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(phoneCell.viewModel?.text, mockShippingInfo.phoneNumber)
    }
        
    func testReuseShippingInfo_RequireCountryCode() {
        mockMethodProvider.session.requiredBillingContactFields = [.countryCode]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertNil(sectionController.context.cellForItem(sectionController.sectionItem(.billingFieldAddress)))
        
        guard let countryCell = sectionController.context.cellForItem(sectionController.sectionItem(.billingFieldCountryCode)) as? CountrySelectionCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(countryCell.viewModel?.country?.countryCode, mockShippingInfo.address?.countryCode)
    }
        
    func testReuseShippingInfo_IncompleteAddress() {
        mockMethodProvider.session.requiredBillingContactFields = [.address]
        mockShippingInfo.address?.postcode = nil
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let addressCell = sectionController.context.cellForItem(sectionController.sectionItem(.billingFieldAddress)) as? BillingInfoCell else {
            XCTFail()
            return
        }
        XCTAssert(addressCell.viewModel?.canReusePrefilledAddress == false)
        XCTAssert(addressCell.viewModel?.shouldReusePrefilledAddress == false)
        // can not fully reuse incomplete address info - the reuse toggle is invisible
        // but will still prefill with shipping info
        XCTAssertEqual(addressCell.viewModel?.countryConfigurer.country?.countryCode, mockShippingInfo.address?.countryCode)
        XCTAssertEqual(addressCell.viewModel?.stateConfigurer.text, mockShippingInfo.address?.state)
        XCTAssertEqual(addressCell.viewModel?.cityConfigurer.text, mockShippingInfo.address?.city)
        XCTAssertEqual(addressCell.viewModel?.zipConfigurer.text, mockShippingInfo.address?.postcode)
    }
        
    func testReuseShippingInfo_ReuseToggle() {
        mockMethodProvider.session.requiredBillingContactFields = [.address]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
    
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let addressCell = sectionController.context.cellForItem(sectionController.sectionItem(.billingFieldAddress)) as? BillingInfoCell else {
            XCTFail()
            return
        }
        XCTAssert(addressCell.viewModel?.canReusePrefilledAddress == true)
        XCTAssert(addressCell.viewModel?.shouldReusePrefilledAddress == true)
    
        addressCell.viewModel?.toggleReuseSelection()
        mockViewController.view.layoutIfNeeded()
        XCTAssert(addressCell.viewModel?.canReusePrefilledAddress == true)
        XCTAssert(addressCell.viewModel?.shouldReusePrefilledAddress == false)
    }
        
    func testCheckoutValidation_InvalidCardInfo_ShowsInlineErrors() {
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let cardInfoCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardInfo)) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }

        guard let checkoutButtonCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        // Invalid card number should show inline error (not alert)
        cardInfoCell.viewModel?.cardNumberConfigurer.text = "4111"
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc
        checkoutButtonCell.viewModel?.checkoutAction()
        // Validation failures now show inline errors instead of alerts
        XCTAssertNotNil(cardInfoCell.viewModel?.cardNumberConfigurer.errorHint)
    }

    // MARK: - Checkout Tests

    func testCheckout_ValidCard_CallsConfirmCardPayment() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let cardInfoCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardInfo)) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }

        // Set valid card info
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc

        guard let checkoutButtonCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutButtonCell.viewModel?.checkoutAction()

        XCTAssertTrue(mockFactory.createHandlerCalled)
        XCTAssertTrue(mockFactory.mockHandler.confirmCardPaymentCalled)
        XCTAssertEqual(mockFactory.mockHandler.confirmCardPaymentCard?.number, mockCard.number)
    }

    func testCheckout_ValidCard_PassesCorrectSaveCardFlag() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()

        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.customerId = "customer_id"
        session.requiredBillingContactFields = []
        session.autoSaveCardForFuturePayments = true
        mockMethodProvider.session = session

        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let cardInfoCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardInfo)) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }

        // Set valid card info
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc

        guard let checkoutButtonCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutButtonCell.viewModel?.checkoutAction()

        XCTAssertTrue(mockFactory.mockHandler.confirmCardPaymentCalled)
        XCTAssertEqual(mockFactory.mockHandler.confirmCardPaymentSaveCard, true)
    }

    func testCheckout_Embedded_SetsShowIndicatorFalse() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockSectionProvider.simulateEmbeddedMode()
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let cardInfoCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardInfo)) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }

        // Set valid card info
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc

        guard let checkoutButtonCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutButtonCell.viewModel?.checkoutAction()

        XCTAssertFalse(mockFactory.mockHandler.showIndicator)
    }

    func testCheckout_Embedded_InvalidCard_NotifiesDelegateOfValidationFailure() {
        let mockDelegate = MockValidationFailureDelegate()
        mockSectionProvider.simulateEmbeddedMode(delegate: mockDelegate)
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let cardInfoCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardInfo)) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }

        // Set invalid card info to trigger validation failure
        cardInfoCell.viewModel?.cardNumberConfigurer.text = "4111"
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc

        guard let checkoutButtonCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutButtonCell.viewModel?.checkoutAction()

        XCTAssertTrue(mockDelegate.validationFailedCalled)
        XCTAssertNotNil(mockDelegate.validationFailedView)
    }

    func testCheckout_NonEmbedded_KeepsShowIndicatorTrue() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        guard let cardInfoCell = sectionController.context.cellForItem(sectionController.sectionItem(.cardInfo)) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }

        // Set valid card info
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc

        guard let checkoutButtonCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutButtonCell.viewModel?.checkoutAction()

        XCTAssertTrue(mockFactory.mockHandler.showIndicator)
    }
}

// MARK: - Item Identifiers (mirroring NewCardPaymentSectionController)
private extension String {
    static let accordionKey = "accordionKey"
    static let consentToggle = "consentToggle"
    static let cardInfo = "cardInfo"
    static let checkoutButton = "checkoutButton"
    static let saveCardToggle = "saveCardToggle"
    static let unionPayWarning = "unionPayWarning"
    static let cardholderName = "cardholderName"
    static let billingFieldEmail = "billingFieldEmail"
    static let billingFieldPhone = "billingFieldPhone"
    static let billingFieldAddress = "billingFieldAddress"
    static let billingFieldCountryCode = "billingFieldCountryCode"
}
