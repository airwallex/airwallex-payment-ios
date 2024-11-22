//
//  AWXPaymentConsentRequestTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/8/23.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentRequest.h"
#import "AWXDevice.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentMethod.h"
#import <XCTest/XCTest.h>

@interface AWXPaymentConsentRequestTest : XCTestCase

@end

@implementation AWXPaymentConsentRequestTest

- (void)testCreatePaymentConsentRequestParameters {
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];

    AWXPaymentMethod *method = [AWXPaymentMethod new];
    method.type = @"applepay";
    NSDictionary *dict = @{@"data": @"test", @"signature": @"abc"};
    method.additionalParams = dict;

    request.paymentMethod = method;
    request.merchantTriggerReason = AirwallexMerchantTriggerReasonScheduled;
    XCTAssertEqualObjects(request.parameters[@"merchant_trigger_reason"], @"scheduled");
    NSDictionary *methodDict = @{@"applepay": dict, @"type": @"applepay"};
    XCTAssertEqualObjects(request.parameters[@"payment_method"], methodDict);
}

- (void)testGetPaymentConsentsRequest {
    NSString *status = @"VERIFIED";
    AWXGetPaymentConsentsRequest *request = [AWXGetPaymentConsentsRequest new];
    request.merchantTriggerReason = AirwallexMerchantTriggerReasonScheduled;
    request.nextTriggeredBy = FormatNextTriggerByType(AirwallexNextTriggerByCustomerType);
    request.status = status;
    XCTAssertEqualObjects(request.path, @"/api/v1/pa/payment_consents");
    XCTAssertEqual(request.method, AWXHTTPMethodGET);
    XCTAssertEqualObjects(request.parameters[@"merchant_trigger_reason"], @"scheduled");
    XCTAssertEqualObjects(request.parameters[@"status"], status);
    XCTAssertEqualObjects(request.parameters[@"next_triggered_by"], @"customer");
    XCTAssertEqual(request.responseClass, AWXGetPaymentConsentsResponse.class);
}

- (void)testVerifyPaymentConsentRequestParameters {
    AWXVerifyPaymentConsentRequest *request = [AWXVerifyPaymentConsentRequest new];

    AWXPaymentMethod *method = [AWXPaymentMethod new];
    method.type = @"applepay";
    NSDictionary *dict = @{@"data": @"test", @"signature": @"abc"};
    method.additionalParams = dict;

    request.amount = [NSDecimalNumber one];
    request.currency = @"AUD";
    request.options = method;
    NSDictionary *methodDict = @{@"applepay": @{@"amount": @"1", @"currency": @"AUD"}};
    XCTAssertEqualObjects(request.parameters[@"verification_options"], methodDict);
    
    AWXDevice *device = [AWXDevice new];
    device.deviceId = @"abcd";
    request.device = device;
    XCTAssertEqualObjects(request.parameters[@"device_data"], device.encodeToJSON);
}

@end
