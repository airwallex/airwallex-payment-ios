//
//  AWXPaymentConsentRequestTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2022/8/23.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentRequest.h"
#import <XCTest/XCTest.h>

@interface AWXPaymentConsentRequestTest : XCTestCase

@end

@implementation AWXPaymentConsentRequestTest

- (void)testCreatePaymentConsentRequestParameters {
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.merchantTriggerReason = AirwallexMerchantTriggerReasonScheduled;
    XCTAssertEqualObjects(request.parameters[@"merchant_trigger_reason"], @"scheduled");
}

@end
