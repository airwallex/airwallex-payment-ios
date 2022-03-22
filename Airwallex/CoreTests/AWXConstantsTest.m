//
//  AWXConstantsTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXConstants.h"

@interface AWXConstantsTest : XCTestCase

@end

@implementation AWXConstantsTest

- (void)testApplePayKey {
    XCTAssertEqualObjects(AWXApplePayKey, @"applepay");
}

- (void)testApplePaySupportedNetworks {
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkVisa]);
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkMasterCard]);
    XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkChinaUnionPay]);
    if (@available(iOS 12.0, *)) {
        XCTAssertTrue([AWXApplePaySupportedNetworks() containsObject:PKPaymentNetworkMaestro]);
    }
}

@end
