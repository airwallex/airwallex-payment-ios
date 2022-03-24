//
//  AWXOneOffSessionRequestTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXOneOffSession+Request.h"

@interface AWXOneOffSessionRequestTest : XCTestCase

@end

@implementation AWXOneOffSessionRequestTest

- (void)testMakePaymentRequest
{
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.countryCode = @"AU";
    
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    session.paymentIntent = intent;
    intent.currency = @"AUD";
    intent.amount = [[NSDecimalNumber alloc] initWithInt:50];
    
    NSString *merchantIdentifier = @"merchantIdentifier";
    AWXApplePayOptions *options = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:merchantIdentifier];
    session.applePayOptions = options;
    options.supportedCountries = [NSSet setWithObjects:@"AU", @"US", nil];
    options.shippingType = PKShippingTypeDelivery;
    options.totalPriceLabel = @"totalPrice";
    
    PKContact *shippingContact = [PKContact new];
    shippingContact.phoneNumber = [[CNPhoneNumber alloc] initWithStringValue:@"61412345678"];
    options.shippingContact = shippingContact;
    
    options.merchantCapabilities = PKMerchantCapability3DS;
    
    PKContact *billingContact = [PKContact new];
    NSPersonNameComponents *components = [NSPersonNameComponents new];
    components.givenName = @"First";
    components.familyName = @"Last";
    
    billingContact.name = components;
    options.billingContact = billingContact;
    
    PKShippingMethod *method = [PKShippingMethod new];
    method.identifier = @"identifier";
    method.label = @"delivery";
    method.amount = [[NSDecimalNumber alloc] initWithInt:10];
    
    options.shippingMethods = [NSArray arrayWithObject:method];
    options.requiredShippingContactFields = [NSSet setWithObject:PKContactFieldName];
    options.requiredBillingContactFields = [NSSet setWithObject:PKContactFieldPhoneNumber];
    
    PKPaymentRequest *request = [session makePaymentRequestOrError:nil];
    
    XCTAssertEqual(request.paymentSummaryItems.count, 1);
    XCTAssertEqualObjects(request.paymentSummaryItems[0].amount, intent.amount);
    XCTAssertEqualObjects(request.paymentSummaryItems[0].label, options.totalPriceLabel);
    XCTAssertEqual(request.paymentSummaryItems[0].type, PKPaymentSummaryItemTypeFinal);
    
    XCTAssertEqualObjects(request.merchantIdentifier, merchantIdentifier);
    XCTAssertEqual(request.merchantCapabilities, options.merchantCapabilities);
    XCTAssertEqualObjects(request.countryCode, session.countryCode);
    XCTAssertEqualObjects(request.currencyCode, intent.currency);
    XCTAssertEqualObjects(request.supportedNetworks, AWXApplePaySupportedNetworks());
    XCTAssertEqualObjects(request.shippingContact, options.shippingContact);
    XCTAssertEqual(request.shippingType, options.shippingType);
    XCTAssertEqualObjects(request.shippingMethods, options.shippingMethods);
    XCTAssertEqualObjects(request.billingContact, options.billingContact);
    XCTAssertEqualObjects(request.requiredBillingContactFields, options.requiredBillingContactFields);
    XCTAssertEqualObjects(request.requiredShippingContactFields, options.requiredShippingContactFields);
    XCTAssertEqualObjects(request.supportedCountries, options.supportedCountries);
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

@end
