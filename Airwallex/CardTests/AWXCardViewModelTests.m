//
//  AWXCardViewModelTests.m
//  CardTests
//
//  Created by Hector.Huang on 2022/9/23.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWX3DSActionProvider.h"
#import "AWXCard.h"
#import "AWXCardProvider.h"
#import "AWXCardValidator.h"
#import "AWXCardViewModel.h"
#import "AWXCountry.h"
#import "AWXDefaultActionProvider.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSession.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface AWXCardViewModelTests : XCTestCase

@end

@implementation AWXCardViewModelTests

- (void)testSetReusesShippingAsBillingInformationWhenBillingIsNil {
    NSString *error;
    AWXCardViewModel *viewModel = [self mockOneOffViewModel];
    BOOL isUpdated = [viewModel setReusesShippingAsBillingInformation:true error:&error];
    XCTAssertEqualObjects(error, NSLocalizedString(@"No shipping address configured.", nil));
    XCTAssertFalse(viewModel.isReusingShippingAsBillingInformation);
    XCTAssertFalse(isUpdated);

    isUpdated = [viewModel setReusesShippingAsBillingInformation:false error:&error];
    XCTAssertFalse(viewModel.isReusingShippingAsBillingInformation);
    XCTAssertTrue(isUpdated);
}

- (void)testSetReusesShippingAsBillingInformationWhenHasBilling {
    NSString *error;
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.billing = [AWXPlaceDetails new];
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    BOOL isUpdated = [viewModel setReusesShippingAsBillingInformation:true error:&error];
    XCTAssertTrue(viewModel.isReusingShippingAsBillingInformation);
    XCTAssertTrue(isUpdated);
}

- (void)testIsBillingInformationRequired {
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.isBillingInformationRequired = false;
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    XCTAssertFalse(viewModel.isBillingInformationRequired);
}

- (void)testIsCardSavingEnabledWhenOneOffSessionWithCustomerId {
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    session.paymentIntent = intent;
    intent.customerId = @"customerId";
    session.paymentIntent = intent;
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    XCTAssertTrue(viewModel.isCardSavingEnabled);
}

- (void)testIsCardSavingEnabledWhenRecurringSession {
    AWXCardViewModel *viewModel = [self mockRecurringViewModel];
    XCTAssertFalse(viewModel.isCardSavingEnabled);
}

- (void)testInitialBilling {
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXPlaceDetails *billing = [AWXPlaceDetails new];
    billing.firstName = @"John";
    session.billing = billing;
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    XCTAssertEqual(viewModel.initialBilling.firstName, @"John");
}

- (void)testMakeBilling {
    AWXCardViewModel *viewModel = [self mockOneOffViewModel];
    AWXCountry *country = [AWXCountry new];
    country.countryCode = @"AU";
    viewModel.selectedCountry = country;
    AWXPlaceDetails *billing = [viewModel makeBillingWithFirstName:@"John"
                                                          lastName:@"Citizen"
                                                             email:@"abc@test.com"
                                                       phoneNumber:@"0451833485"
                                                             state:@"VIC"
                                                              city:@"Melbourne"
                                                            street:@"Collins Street"
                                                          postcode:@"3000"];
    XCTAssertEqual(billing.firstName, @"John");
    XCTAssertEqual(billing.lastName, @"Citizen");
    XCTAssertEqual(billing.email, @"abc@test.com");
    XCTAssertEqual(billing.phoneNumber, @"0451833485");
    XCTAssertEqual(billing.address.countryCode, @"AU");
    XCTAssertEqual(billing.address.state, @"VIC");
    XCTAssertEqual(billing.address.city, @"Melbourne");
    XCTAssertEqual(billing.address.street, @"Collins Street");
    XCTAssertEqual(billing.address.postcode, @"3000");
}

- (void)testMakeBillingWhenReusingSessionBilling {
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXAddress *address = [AWXAddress new];
    address.countryCode = @"SES";
    address.state = @"SESSION";
    address.city = @"Session City";
    address.street = @"Session St";
    address.postcode = @"Session Code";

    AWXPlaceDetails *billing = [AWXPlaceDetails new];
    billing.firstName = @"James";
    billing.lastName = @"Session";
    billing.email = @"session@example.com";
    billing.phoneNumber = @"1-800-Session";
    billing.address = address;

    session.billing = billing;
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    [viewModel setReusesShippingAsBillingInformation:YES error:NULL];

    AWXCountry *country = [AWXCountry new];
    country.countryCode = @"AU";
    viewModel.selectedCountry = country;
    AWXPlaceDetails *inputBilling = [viewModel makeBillingWithFirstName:@"John"
                                                               lastName:@"Citizen"
                                                                  email:@"abc@test.com"
                                                            phoneNumber:@"0451833485"
                                                                  state:@"VIC"
                                                                   city:@"Melbourne"
                                                                 street:@"Collins Street"
                                                               postcode:@"3000"];

    XCTAssertEqual(inputBilling.firstName, session.billing.firstName);
    XCTAssertEqual(inputBilling.lastName, session.billing.lastName);
    XCTAssertEqual(inputBilling.email, session.billing.email);
    XCTAssertEqual(inputBilling.phoneNumber, session.billing.phoneNumber);
    XCTAssertEqual(inputBilling.address.countryCode, session.billing.address.countryCode);
    XCTAssertEqual(inputBilling.address.state, session.billing.address.state);
    XCTAssertEqual(inputBilling.address.city, session.billing.address.city);
    XCTAssertEqual(inputBilling.address.street, session.billing.address.street);
    XCTAssertEqual(inputBilling.address.postcode, session.billing.address.postcode);
}

- (void)testMakeCard {
    AWXCardViewModel *viewModel = [self mockOneOffViewModel];
    AWXCard *card = [viewModel makeCardWithName:@"John Citizen"
                                         number:@"535234234314"
                                         expiry:@"08/25"
                                            cvc:@"077"];
    XCTAssertEqual(card.name, @"John Citizen");
    XCTAssertEqual(card.number, @"535234234314");
    XCTAssertEqualObjects(card.expiryYear, @"2025");
    XCTAssertEqualObjects(card.expiryMonth, @"08");
    XCTAssertEqual(card.cvc, @"077");
}

- (void)testUpdatePaymentIntentId {
    AWXRecurringSession *session = [AWXRecurringSession new];
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    [viewModel updatePaymentIntentId:@"id"];
    XCTAssertEqual(session.paymentIntentId, @"id");
}

- (void)testActionProviderForNextAction {
    AWXCardViewModel *viewModel = [self mockOneOffViewModel];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"redirect_form", @"type", nil];
    AWXConfirmPaymentNextAction *nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:dict];

    AWXDefaultActionProvider *actionProvider = [viewModel actionProviderForNextAction:nextAction withDelegate:nil];
    XCTAssertTrue([actionProvider isKindOfClass:[AWX3DSActionProvider class]]);
}

- (void)testPreparedProviderWithDelegate {
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"AU";
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    AWXCardProvider *provider = [viewModel preparedProviderWithDelegate:nil];
    XCTAssertEqual(provider.session.countryCode, @"AU");
}

- (void)testConfirmPaymentWithInvalidBillingDetails {
    NSString *error;
    AWXCardViewModel *viewModel = [self mockOneOffViewModel];
    [viewModel confirmPaymentWithProvider:[viewModel preparedProviderWithDelegate:nil]
                                  billing:[AWXPlaceDetails new]
                                     card:[AWXCard new]
                   shouldStoreCardDetails:true
                                    error:&error];
    XCTAssertEqualObjects(error, @"Invalid first name");
}

- (void)testConfirmPaymentWithoutRequiredBillingDetails {
    NSString *error;
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.isBillingInformationRequired = YES;
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    [viewModel confirmPaymentWithProvider:[viewModel preparedProviderWithDelegate:nil]
                                  billing:nil
                                     card:[AWXCard new]
                   shouldStoreCardDetails:true
                                    error:&error];
    XCTAssertEqualObjects(error, @"No billing address provided.");
}

- (void)testConfirmPaymentWithoutCardDetails {
    NSString *error;
    AWXCardViewModel *viewModel = [self mockOneOffViewModel];
    AWXCountry *country = [AWXCountry new];
    country.countryCode = @"AU";
    viewModel.selectedCountry = country;
    AWXPlaceDetails *billing = [viewModel makeBillingWithFirstName:@"John"
                                                          lastName:@"Citizen"
                                                             email:@"abc@test.com"
                                                       phoneNumber:@"0451833485"
                                                             state:@"VIC"
                                                              city:@"Melbourne"
                                                            street:@"Collins Street"
                                                          postcode:@"3000"];
    [viewModel confirmPaymentWithProvider:[viewModel preparedProviderWithDelegate:nil]
                                  billing:billing
                                     card:[AWXCard new]
                   shouldStoreCardDetails:true
                                    error:&error];
    XCTAssertEqualObjects(error, @"Invalid card number");
}

- (void)testConfirmPaymentWithCardWithoutOptionalBilling {
    NSString *error;
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.isBillingInformationRequired = NO;
    AWXCardViewModel *viewModel = [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
    AWXCard *card = [viewModel makeCardWithName:@"John Citizen"
                                         number:@"535234234314"
                                         expiry:@"08/25"
                                            cvc:@"077"];
    id cardProviderMock = OCMClassMock([AWXCardProvider class]);
    OCMStub([cardProviderMock alloc]).andReturn(cardProviderMock);

    [viewModel confirmPaymentWithProvider:cardProviderMock
                                  billing:nil
                                     card:card
                   shouldStoreCardDetails:true
                                    error:&error];
    OCMVerify(times(1), [cardProviderMock confirmPaymentIntentWithCard:[OCMArg any] billing:[OCMArg isNil] saveCard:true]);
}

- (void)testConfirmPaymentWithBillingAndCard {
    NSString *error;
    AWXCardViewModel *viewModel = [self mockOneOffViewModel];
    AWXCountry *country = [AWXCountry new];
    country.countryCode = @"AU";
    viewModel.selectedCountry = country;
    AWXPlaceDetails *billing = [viewModel makeBillingWithFirstName:@"John"
                                                          lastName:@"Citizen"
                                                             email:@"abc@test.com"
                                                       phoneNumber:@"0451833485"
                                                             state:@"VIC"
                                                              city:@"Melbourne"
                                                            street:@"Collins Street"
                                                          postcode:@"3000"];
    AWXCard *card = [viewModel makeCardWithName:@"John Citizen"
                                         number:@"535234234314"
                                         expiry:@"08/25"
                                            cvc:@"077"];
    id cardProviderMock = OCMClassMock([AWXCardProvider class]);
    OCMStub([cardProviderMock alloc]).andReturn(cardProviderMock);

    BOOL (^billingVerification)(id) = ^BOOL(id value) {
        AWXPlaceDetails *validatedBilling = (AWXPlaceDetails *)value;
        XCTAssertEqual(validatedBilling.lastName, billing.lastName);
        XCTAssertEqual(validatedBilling.email, billing.email);
        XCTAssertEqual(validatedBilling.address.postcode, billing.address.postcode);

        return true;
    };

    OCMExpect([cardProviderMock confirmPaymentIntentWithCard:[OCMArg isNotNil]
                                                     billing:[OCMArg checkWithBlock:billingVerification]
                                                    saveCard:true]);

    [viewModel confirmPaymentWithProvider:cardProviderMock
                                  billing:billing
                                     card:card
                   shouldStoreCardDetails:true
                                    error:&error];

    OCMVerify(times(1), [cardProviderMock confirmPaymentIntentWithCard:[OCMArg isNotNil] billing:[OCMArg isNotNil] saveCard:true]);
    OCMVerifyAll(cardProviderMock);
}

- (void)testMakeDisplayedCardBrands {
    AWXCardViewModel *viewModel = [self mockOneOffViewModelWithCardSchemes];
    XCTAssertEqual([viewModel makeDisplayedCardBrands].count, 2);
    XCTAssertEqual([[viewModel makeDisplayedCardBrands][0] intValue], AWXBrandTypeVisa);
    XCTAssertEqual([[viewModel makeDisplayedCardBrands][1] intValue], AWXBrandTypeMastercard);
}

- (void)testValidationMessageFromCardNumber {
    AWXCardViewModel *viewModel = [self mockOneOffViewModelWithCardSchemes];
    XCTAssertNil([viewModel validationMessageFromCardNumber:@"5555555555554444"]);
    XCTAssertEqualObjects([viewModel validationMessageFromCardNumber:@"55"], @"Card number is invalid");
    XCTAssertEqualObjects([viewModel validationMessageFromCardNumber:@"378282246310005"], @"Card not supported for payment");
    XCTAssertEqualObjects([viewModel validationMessageFromCardNumber:@"55"], @"Card number is invalid");
}

- (AWXCardViewModel *)mockOneOffViewModel {
    AWXOneOffSession *session = [AWXOneOffSession new];
    return [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
}

- (AWXCardViewModel *)mockRecurringViewModel {
    AWXRecurringSession *session = [AWXRecurringSession new];
    return [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:NULL];
}

- (AWXCardViewModel *)mockOneOffViewModelWithCardSchemes {
    AWXOneOffSession *session = [AWXOneOffSession new];
    AWXCardScheme *visaScheme = [AWXCardScheme new];
    visaScheme.name = @"visa";
    AWXCardScheme *mcScheme = [AWXCardScheme new];
    mcScheme.name = @"mastercard";
    return [[AWXCardViewModel alloc] initWithSession:session supportedCardSchemes:@[visaScheme, mcScheme]];
}

@end
