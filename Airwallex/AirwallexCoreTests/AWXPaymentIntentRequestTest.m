//
//  AWXPaymentIntentRequestTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/12/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentIntentRequest.h"
#import "AWXDevice.h"
#import <XCTest/XCTest.h>
@import AirwallexCore;

@interface AWXPaymentIntentRequestTest : XCTestCase

@property (nonatomic, strong) AWXDevice *device;

@end

@implementation AWXPaymentIntentRequestTest

- (void)setUp {
    [super setUp];
    AWXDevice *device = [AWXDevice new];
    device.deviceId = @"abcd";
    self.device = device;
}

- (void)testConfirmRequestParameters {
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.device = _device;
    XCTAssertEqualObjects(request.parameters[@"device_data"], _device.encodeToJSON);
}

- (void)testConfirmRequestWithPaymentMethod {
    // Test when paymentMethod is provided (without paymentConsent)
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = @"int_123456";
    request.requestId = @"req_abcdef";

    // Create a payment method
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = @"card";

    AWXCard *card = [AWXCard new];
    card.number = @"4242424242424242";
    card.expiryMonth = @"12";
    card.expiryYear = @"25";
    card.cvc = @"123";

    paymentMethod.card = card;
    request.paymentMethod = paymentMethod;

    // Get parameters
    NSDictionary *parameters = request.parameters;

    // Verify payment_method is included and properly encoded
    XCTAssertNotNil(parameters[@"payment_method"]);

    // The payment_method should be the encoded JSON from paymentMethod
    NSDictionary *expectedPaymentMethod = @{
        @"type": @"card",
        @"card": @{
            @"number": @"4242424242424242",
            @"expiry_month": @"12",
            @"expiry_year": @"25",
            @"cvc": @"123"
        }
    };
    XCTAssertEqualObjects(parameters[@"payment_method"], expectedPaymentMethod);

    // Verify other parameters
    XCTAssertEqualObjects(parameters[@"request_id"], @"req_abcdef");
    XCTAssertEqualObjects(parameters[@"save_payment_method"], @(NO)); // Default is NO
}

- (void)testConfirmRequestWithPaymentConsent {
    // Test when paymentConsent with ID is provided
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = @"int_123456";
    request.requestId = @"req_abcdef";

    // Create a payment consent
    AWXPaymentConsent *paymentConsent = [AWXPaymentConsent new];
    paymentConsent.Id = @"cst_987654";
    request.paymentConsent = paymentConsent;

    // Create a payment method with CVC (for payment_consent_reference)
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    AWXCard *card = [AWXCard new];
    card.cvc = @"123";
    paymentMethod.card = card;
    request.paymentMethod = paymentMethod;

    // Get parameters
    NSDictionary *parameters = request.parameters;

    // Verify payment_consent_reference is included instead of payment_method
    XCTAssertNil(parameters[@"payment_method"]);
    XCTAssertNotNil(parameters[@"payment_consent_reference"]);

    // Check payment_consent_reference structure
    NSDictionary *consentRef = parameters[@"payment_consent_reference"];
    XCTAssertEqualObjects(consentRef[@"id"], @"cst_987654");
    XCTAssertEqualObjects(consentRef[@"cvc"], @"123");
}

- (void)testConfirmRequestWithConsentOptions {
    // Test when consentOptions is provided
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = @"int_123456";
    request.requestId = @"req_abcdef";

    // Create payment method
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = @"card";
    request.paymentMethod = paymentMethod;

    // Set consentOptions
    NSDictionary *consentOptions = @{
        @"next_triggered_by": @"customer",
        @"merchant_trigger_reason": @"unscheduled"
    };
    request.consentOptions = consentOptions;

    // Get parameters
    NSDictionary *parameters = request.parameters;

    // Verify payment_consent is included with correct values
    XCTAssertNotNil(parameters[@"payment_consent"]);
    XCTAssertEqualObjects(parameters[@"payment_consent"], consentOptions);

    // Verify payment_method is also included (both can be present)
    XCTAssertNotNil(parameters[@"payment_method"]);
}

- (void)testConfirmRequestPath {
    // Test the path method of AWXConfirmPaymentIntentRequest
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = @"int_test123456";

    // Verify the path is correctly constructed with the intentId
    NSString *expectedPath = @"/api/v1/pa/payment_intents/int_test123456/confirm";
    XCTAssertEqualObjects([request path], expectedPath);

    // Test with a different intentId
    request.intentId = @"int_different789";
    expectedPath = @"/api/v1/pa/payment_intents/int_different789/confirm";
    XCTAssertEqualObjects([request path], expectedPath);
}

- (void)testContinueRequestParameter {
    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.device = _device;
    XCTAssertEqualObjects(request.parameters[@"device_data"], _device.encodeToJSON);
}

@end
