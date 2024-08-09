//
//  AWXSessionTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2021/9/1.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXSession.h"
#import "AWXTestUtils.h"
#import "XCTestCase+Utils.h"
#import <XCTest/XCTest.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXSessionTest : XCTestCase

@property (nonatomic, strong) AWXPaymentIntent *paymentIntent;

@end

@implementation AWXSessionTest

- (void)testOneOffSession {
    AWXPlaceDetails *billing = [AWXPlaceDetails decodeFromJSON:[AWXTestUtils jsonNamed:@"Billing"]];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.billing = billing;
    session.returnURL = @"airwallex://";
    XCTAssertNil(session.customerId);
    XCTAssertTrue(session.autoCapture);
}

- (void)testRecurringSession {
    AWXPlaceDetails *billing = [AWXPlaceDetails decodeFromJSON:[AWXTestUtils jsonNamed:@"Billing"]];
    AWXRecurringSession *session = [AWXRecurringSession new];
    session.billing = billing;
    session.returnURL = @"airwallex://";
    session.currency = @"HKD";
    session.amount = [NSDecimalNumber decimalNumberWithString:@"0.1"];
    session.customerId = nil;
    session.nextTriggerByType = AirwallexNextTriggerByCustomerType;
    session.requiresCVC = YES;
    session.merchantTriggerReason = AirwallexMerchantTriggerReasonUnscheduled;
    XCTAssertNotNil(session.customerPaymentConsents);
    XCTAssertNotNil(session.customerPaymentMethods);
    XCTAssertNil(session.customerId);
    XCTAssertNotNil(session.currency);
    XCTAssertNotNil(session.amount);
}

- (void)testRecurringWithIntentSession {
    AWXPlaceDetails *billing = [AWXPlaceDetails decodeFromJSON:[AWXTestUtils jsonNamed:@"Billing"]];
    AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
    session.billing = billing;
    session.returnURL = @"airwallex://";
    session.nextTriggerByType = AirwallexNextTriggerByCustomerType;
    session.requiresCVC = YES;
    session.merchantTriggerReason = AirwallexMerchantTriggerReasonUnscheduled;
    XCTAssertNil(session.customerId);
    XCTAssertTrue(session.autoCapture);
}

@end
