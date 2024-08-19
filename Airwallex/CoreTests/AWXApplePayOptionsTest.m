//
//  AWXApplePayOptionsTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayOptions.h"
#import "AWXConstants.h"
#import <XCTest/XCTest.h>

@interface AWXApplePayOptionsTest : XCTestCase

@end

@implementation AWXApplePayOptionsTest

- (void)testInitWithMerchantIdentifier {
    NSString *identifier = @"merchantIdentifier";
    AWXApplePayOptions *options = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:identifier];

    XCTAssertEqualObjects(options.merchantIdentifier, identifier);
    XCTAssertEqualObjects(options.requiredBillingContactFields, [NSSet new]);
    XCTAssertNil(options.totalPriceLabel);
    XCTAssertNil(options.supportedCountries);
    XCTAssertNil(options.additionalPaymentSummaryItems);
    XCTAssertEqualObjects(options.supportedNetworks, AWXApplePaySupportedNetworks());
}

@end
