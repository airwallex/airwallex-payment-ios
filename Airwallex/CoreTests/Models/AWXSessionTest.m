//
//  AWXSessionTest.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2021/9/1.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXSession.h"
#import "AWXPlaceDetails.h"
#import "AWXTestUtils.h"
#import "XCTestCase+Utils.h"
#import <XCTest/XCTest.h>

@interface AWXSessionTest : XCTestCase

@property (nonatomic, strong) AWXPaymentIntent *paymentIntent;

@end

@implementation AWXSessionTest

- (void)setUp {
    [super setUp];
    [self prepareEphemeralKeys:^(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error) {
        self.paymentIntent = paymentIntent;
        XCTAssertNotNil(paymentIntent);
        XCTAssertNil(error);
    }];
}

- (void)testOneOffSession {
    AWXPlaceDetails *billing = [AWXPlaceDetails decodeFromJSON:[AWXTestUtils jsonNamed:@"Billing"]];
    AWXOneOffSession *session = [AWXOneOffSession new];
    session.billing = billing;
    session.returnURL = @"airwallex://";
    session.paymentIntent = self.paymentIntent;
    session.autoCapture = YES;
    XCTAssertNotNil(session.customerPaymentConsents);
    XCTAssertNotNil(session.customerPaymentMethods);
    XCTAssertNil(session.customerId);
    XCTAssertNotNil(session.currency);
    XCTAssertNotNil(session.amount);
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
    session.paymentIntent = self.paymentIntent;
    session.nextTriggerByType = AirwallexNextTriggerByCustomerType;
    session.requiresCVC = YES;
    session.autoCapture = YES;
    session.merchantTriggerReason = AirwallexMerchantTriggerReasonUnscheduled;
    XCTAssertNotNil(session.customerPaymentConsents);
    XCTAssertNotNil(session.customerPaymentMethods);
    XCTAssertNil(session.customerId);
    XCTAssertNotNil(session.currency);
    XCTAssertNotNil(session.amount);
}

@end
