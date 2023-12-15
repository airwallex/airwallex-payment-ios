//
//  AWXPaymentConsentRequestTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/8/23.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import <XCTest/XCTest.h>

@interface AWXPaymentConsentRequestTest : XCTestCase

@end

@implementation AWXPaymentConsentRequestTest

- (void)testCreatePaymentConsentRequestParameters {
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.merchantTriggerReason = AirwallexMerchantTriggerReasonScheduled;
    XCTAssertEqualObjects(request.parameters[@"merchant_trigger_reason"], @"scheduled");
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

@end
