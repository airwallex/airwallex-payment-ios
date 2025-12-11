//
//  NewCardPaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
@testable @_spi(AWX) import AirwallexPayment
import AirwallexCore

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
        XCTAssertTrue(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.consentToggle)))
        mockMethodProvider.consents = []
        mockManager.performUpdates()
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.consentToggle)))
    }
    
    func testInitWithAccordion() {
        mockSectionProvider.layout = .accordion
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentNew)
        mockViewController.view.layoutIfNeeded()
        XCTAssertNotNil(sectionController.context.cellForItem(sectionController.identifier(for: NewCardPaymentSectionController.Item.accordionKey)))
    }
    
    func testRequiredBillingFields_None() {
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.cardholderName)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldEmail)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldPhone)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldCountryCode)))
    }
    
    func testRequiredBillingFields_AddressAndCountryCode() {
        mockMethodProvider.session.requiredBillingContactFields = [.name, .address, .countryCode]
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertTrue(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.cardholderName)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldEmail)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldPhone)))
        XCTAssertTrue(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldCountryCode)))
    }
    
    func testRequiredBillingFields_EmailAndPhone() {
        mockMethodProvider.session.requiredBillingContactFields = [.phone, .email, .countryCode]
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.cardholderName)))
        XCTAssertTrue(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldEmail)))
        XCTAssertTrue(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldPhone)))
        XCTAssertFalse(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)))
        XCTAssertTrue(sectionController.items.contains(sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldCountryCode)))
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
        let itemIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.saveCardToggle)
        XCTAssertTrue(sectionController.items.contains(itemIdentifier))

        guard let cell = sectionController.context.cellForItem(itemIdentifier) as? CheckBoxCell,
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
        let itemIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.saveCardToggle)
        XCTAssertFalse(sectionController.items.contains(itemIdentifier))
        XCTAssertNil(sectionController.context.cellForItem(itemIdentifier))
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
        let itemIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.saveCardToggle)
        XCTAssertTrue(sectionController.items.contains(itemIdentifier))

        guard let cell = sectionController.context.cellForItem(itemIdentifier) as? CheckBoxCell,
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
        let itemIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.saveCardToggle)
        XCTAssertFalse(sectionController.items.contains(itemIdentifier))
        XCTAssertNil(sectionController.context.cellForItem(itemIdentifier))
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
        let itemIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.saveCardToggle)
        XCTAssertFalse(sectionController.items.contains(itemIdentifier))
        XCTAssertNil(sectionController.context.cellForItem(itemIdentifier))
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
        let itemIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.saveCardToggle)
        XCTAssertTrue(sectionController.items.contains(itemIdentifier))
        guard let toggleCell = sectionController.context.cellForItem(itemIdentifier) as? CheckBoxCell else {
            XCTFail()
            return
        }
        XCTAssert(toggleCell.viewModel?.isSelected == true)
        toggleCell.viewModel?.toggleSelection()
        XCTAssert(toggleCell.viewModel?.isSelected == false)
        toggleCell.viewModel?.toggleSelection()

        let cardIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.cardInfo)
        guard let cardInfoCell = sectionController.context.cellForItem(cardIdentifier) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }
        let textField = UITextField()
        _ = cardInfoCell.viewModel?.cardNumberConfigurer.textField(
            textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "62"
        )
        let unionPayWarningItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.unionPayWarning)
        (cardInfoCell.allFields.first as? CardNumberTextField)?.editingDidEnd(textField)
        XCTAssertTrue(sectionController.items.contains(unionPayWarningItem))
    }
    
    func testReuseShippingInfo_All() {
        mockMethodProvider.session.requiredBillingContactFields = [.address, .email, .name, .phone,]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let addressItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)
        guard let addressCell = sectionController.context.cellForItem(addressItem) as? BillingInfoCell else {
            XCTFail()
            return
        }
        XCTAssert(addressCell.viewModel?.canReusePrefilledAddress == true)
        XCTAssert(addressCell.viewModel?.shouldReusePrefilledAddress == true)
        XCTAssertEqual(addressCell.viewModel?.countryConfigurer.country?.countryCode, mockShippingInfo.address?.countryCode)
        XCTAssertEqual(addressCell.viewModel?.stateConfigurer.text, mockShippingInfo.address?.state)
        XCTAssertEqual(addressCell.viewModel?.cityConfigurer.text, mockShippingInfo.address?.city)
        XCTAssertEqual(addressCell.viewModel?.zipConfigurer.text, mockShippingInfo.address?.postcode)
        
        let emailItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldEmail)
        guard let emailCell = sectionController.context.cellForItem(emailItem) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(emailCell.viewModel?.text, mockShippingInfo.email)
        
        
        let nameItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.cardholderName)
        guard let nameCell = sectionController.context.cellForItem(nameItem) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(nameCell.viewModel?.text, mockShippingInfo.fullName)
        
        let phoneItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldPhone)
        guard let phoneCell = sectionController.context.cellForItem(phoneItem) as? InfoCollectorCell else {
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
        let addressItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)
        XCTAssertNil(sectionController.context.cellForItem(addressItem))
        
        let countryCodeItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldCountryCode)
        guard let countryCell = sectionController.context.cellForItem(countryCodeItem) as? CountrySelectionCell else {
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
        let addressItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)
        guard let addressCell = sectionController.context.cellForItem(addressItem) as? BillingInfoCell else {
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
        let addressItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)
        guard let addressCell = sectionController.context.cellForItem(addressItem) as? BillingInfoCell else {
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
        
    func testCheckoutValidation_InvalidCardInfo() {
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let cardIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.cardInfo)
        guard let cardInfoCell = sectionController.context.cellForItem(cardIdentifier) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }
        
        let checkoutButtonIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.checkoutButton)
        guard let checkoutButtonCell = sectionController.context.cellForItem(checkoutButtonIdentifier) as? CheckoutButtonCell else {
            XCTFail()
            return
        }
        
        XCTAssertNoThrow(try AWXCardValidator.validate(
            card: mockCard,
            nameRequired: false,
            supportedSchemes: AWXCardScheme.allAvailable
        ))
        // invalid card number
        cardInfoCell.viewModel?.cardNumberConfigurer.text = "4111"
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc
        checkoutButtonCell.viewModel?.checkoutAction()
        XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
        XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
        
        // invalid expiry
        mockViewController.presentedViewControllerSpy = nil
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "12/23"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc
        checkoutButtonCell.viewModel?.checkoutAction()
        XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
        XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
        
        // invalid cvc
        mockViewController.presentedViewControllerSpy = nil
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = "11"
        checkoutButtonCell.viewModel?.checkoutAction()
        XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
        XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
    }
    
    func testCheckoutValidation_InvalidBillingInfo() {
        mockMethodProvider.session.requiredBillingContactFields = [.name, .email, .phone, .address]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        
        let checkoutButtonIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.checkoutButton)
        guard let checkoutButtonCell = sectionController.context.cellForItem(checkoutButtonIdentifier) as? CheckoutButtonCell else {
            XCTFail()
            return
        }
        
        let mockProvider = AWXCardProvider(
            delegate: MockProviderDelegate(),
            session: mockMethodProvider.session,
            paymentMethodType: mockMethodProvider.selectedMethod
        )
        let cardIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.cardInfo)
        guard let cardInfoCell = sectionController.context.cellForItem(cardIdentifier) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc
        guard let card = cardInfoCell.viewModel?.cardFromCollectedInfo() else {
            XCTFail()
            return
        }
        card.name = mockShippingInfo.fullName
        XCTAssertNoThrow(try mockProvider.validate(card: card, billing: mockShippingInfo))
        
        do {
            // invalid name
            let nameItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.cardholderName)
            guard let nameCell = sectionController.context.cellForItem(nameItem) as? InfoCollectorCell else {
                XCTFail()
                return
            }
            nameCell.viewModel?.text = nil
            checkoutButtonCell.viewModel?.checkoutAction()
            XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
            XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
            nameCell.viewModel?.text = mockCard.name
        }
        
        do {// invalid email
            mockViewController.presentedViewControllerSpy = nil
            let emailItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldEmail)
            guard let emailCell = sectionController.context.cellForItem(emailItem) as? InfoCollectorCell else {
                XCTFail()
                return
            }
            emailCell.viewModel?.text = nil
            checkoutButtonCell.viewModel?.checkoutAction()
            XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
            XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
            emailCell.viewModel?.text = mockShippingInfo.email
        }
        
        do {// invalid phone
            mockViewController.presentedViewControllerSpy = nil
            let phoneItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldPhone)
            guard let phoneCell = sectionController.context.cellForItem(phoneItem) as? InfoCollectorCell else {
                XCTFail()
                return
            }
            phoneCell.viewModel?.text = nil
            checkoutButtonCell.viewModel?.checkoutAction()
            XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
            XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
            phoneCell.viewModel?.text = mockShippingInfo.phoneNumber
        }
        
        do {// invalid address
            mockViewController.presentedViewControllerSpy = nil
            let addressItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldAddress)
            guard let addressCell = sectionController.context.cellForItem(addressItem) as? BillingInfoCell else {
                XCTFail()
                return
            }
            addressCell.viewModel?.zipConfigurer.text = nil
            checkoutButtonCell.viewModel?.checkoutAction()
            XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
            XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
            addressCell.viewModel?.zipConfigurer.text = mockShippingInfo.address?.postcode
        }
    }
    
    func testCheckoutValidation_InvalidCountryCode() {
        mockMethodProvider.session.requiredBillingContactFields = [.countryCode]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        
        let checkoutButtonIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.checkoutButton)
        guard let checkoutButtonCell = sectionController.context.cellForItem(checkoutButtonIdentifier) as? CheckoutButtonCell else {
            XCTFail()
            return
        }
        
        let mockProvider = AWXCardProvider(
            delegate: MockProviderDelegate(),
            session: mockMethodProvider.session,
            paymentMethodType: mockMethodProvider.selectedMethod
        )
        let cardIdentifier = sectionController.identifier(for: NewCardPaymentSectionController.Item.cardInfo)
        guard let cardInfoCell = sectionController.context.cellForItem(cardIdentifier) as? CardInfoCollectorCell else {
            XCTFail()
            return
        }
        cardInfoCell.viewModel?.cardNumberConfigurer.text = mockCard.number
        cardInfoCell.viewModel?.expireDataConfigurer.text = "\(mockCard.expiryMonth)/\(mockCard.expiryYear.suffix(2))"
        cardInfoCell.viewModel?.cvcConfigurer.text = mockCard.cvc
        guard let card = cardInfoCell.viewModel?.cardFromCollectedInfo() else {
            XCTFail()
            return
        }
        XCTAssertNoThrow(try mockProvider.validate(card: card, billing: mockShippingInfo))
        
        let countryCodeItem = sectionController.identifier(for: NewCardPaymentSectionController.Item.billingFieldCountryCode)
        guard let countryCodeCell = sectionController.context.cellForItem(countryCodeItem) as? CountrySelectionCell else {
            XCTFail()
            return
        }
        print(sectionController.items)
        countryCodeCell.viewModel?.country = nil
        checkoutButtonCell.viewModel?.checkoutAction()
        XCTAssertNotNil(mockViewController.presentedViewControllerSpy)
        XCTAssert(mockViewController.presentedViewControllerSpy is AWXAlertController)
        countryCodeCell.viewModel?.text = mockCard.name
        mockViewController.presentedViewControllerSpy = nil
        
        countryCodeCell.viewModel?.handleUserInteraction()
        XCTAssert(mockViewController.presentedViewControllerSpy is UINavigationController)
    }
}
