//
//  AWXOneOffSessionRequestTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXOneOffSession+Request.h"
#import "AWXPlaceDetails+PKContact.h"

@interface AWXOneOffSessionRequestTest : XCTestCase

@end

@implementation AWXOneOffSessionRequestTest

- (void)testMakePaymentRequest
{
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"AU";
    
    AWXPlaceDetails *details = [AWXPlaceDetails new];
    details.firstName = @"firstName";
    details.lastName = @"lastName";
    
    AWXAddress *address = [AWXAddress new];
    address.street = @"street";
    address.countryCode = @"AU";
    address.city = @"city";
    
    details.address = address;
    
    session.billing = details;
    
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    session.paymentIntent = intent;
    intent.currency = @"AUD";
    intent.amount = [[NSDecimalNumber alloc] initWithInt:50];
    
    AWXApplePayOptions *options = [self makeOptions:nil];
    session.applePayOptions = options;
    
    PKPaymentRequest *request = [session makePaymentRequestOrError:nil];
    
    XCTAssertEqual(request.paymentSummaryItems.count, 1);
    XCTAssertEqualObjects(request.paymentSummaryItems[0].amount, intent.amount);
    XCTAssertEqualObjects(request.paymentSummaryItems[0].label, options.totalPriceLabel);
    XCTAssertEqual(request.paymentSummaryItems[0].type, PKPaymentSummaryItemTypeFinal);
    
    XCTAssertEqualObjects(request.merchantIdentifier, options.merchantIdentifier);
    XCTAssertEqual(request.merchantCapabilities, options.merchantCapabilities);
    XCTAssertEqualObjects(request.countryCode, session.countryCode);
    XCTAssertEqualObjects(request.currencyCode, intent.currency);
    XCTAssertEqualObjects(request.supportedNetworks, AWXApplePaySupportedNetworks());
    XCTAssertEqualObjects(request.billingContact, [session.billing convertToPaymentContact]);
    XCTAssertEqualObjects(request.requiredBillingContactFields, options.requiredBillingContactFields);
    XCTAssertEqualObjects(request.supportedCountries, options.supportedCountries);
}

- (void)testMakePaymentRequestWithCustomPaymentSummaryItems
{
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"AU";
    
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    session.paymentIntent = intent;
    intent.currency = @"AUD";
    intent.amount = [[NSDecimalNumber alloc] initWithInt:50];
    
    PKPaymentSummaryItem *subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"subtotal"
                                                                         amount:[NSDecimalNumber decimalNumberWithMantissa:40 exponent:0 isNegative:NO]];
    PKPaymentSummaryItem *tax = [PKPaymentSummaryItem summaryItemWithLabel:@"gst"
                                                                    amount:[NSDecimalNumber decimalNumberWithMantissa:10 exponent:0 isNegative:NO]];
    AWXApplePayOptions *options = [self makeOptions:@[subtotal, tax]];
    session.applePayOptions = options;
    
    PKPaymentRequest *request = [session makePaymentRequestOrError:nil];
    
    XCTAssertEqual(request.paymentSummaryItems.count, 3);
    XCTAssertEqualObjects(request.paymentSummaryItems[0], subtotal);
    XCTAssertEqualObjects(request.paymentSummaryItems[1], tax);
    XCTAssertEqualObjects(request.paymentSummaryItems[2].label, options.totalPriceLabel);
    XCTAssertEqualObjects(request.paymentSummaryItems[2].amount, session.amount);
}

- (void)testMakePaymentRequestWithNoOptions
{
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.applePayOptions = nil;
    
    NSError *error;
    PKPaymentRequest *request = [session makePaymentRequestOrError:&error];
    
    XCTAssertNil(request);
    XCTAssertNotNil(error);
}

- (void)testMakePaymentRequestWithNoIntent
{
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.applePayOptions = [self makeOptions:nil];
    session.paymentIntent = nil;
    
    NSError *error;
    PKPaymentRequest *request = [session makePaymentRequestOrError:&error];
    
    XCTAssertNil(request);
    XCTAssertNotNil(error);
}

- (AWXApplePayOptions *)makeOptions:(nullable NSArray <PKPaymentSummaryItem *> *)items
{
    AWXApplePayOptions *options = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"merchantIdentifier"];
    
    options.additionalPaymentSummaryItems = items;
    
    options.supportedCountries = [NSSet setWithObjects:@"AU", @"US", nil];
    options.totalPriceLabel = @"totalPrice";
    
    PKContact *shippingContact = [PKContact new];
    shippingContact.phoneNumber = [[CNPhoneNumber alloc] initWithStringValue:@"61412345678"];
    
    options.merchantCapabilities = PKMerchantCapability3DS;
    
    PKShippingMethod *method = [PKShippingMethod new];
    method.identifier = @"identifier";
    method.label = @"delivery";
    method.amount = [[NSDecimalNumber alloc] initWithInt:10];
    
    options.requiredBillingContactFields = [NSSet setWithObject:PKContactFieldPhoneNumber];
    
    return options;
}

@end
