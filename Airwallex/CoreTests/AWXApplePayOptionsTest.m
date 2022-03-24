//
//  AWXApplePayOptionsTest.m
//  CoreTests
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXApplePayOptions.h"

@interface AWXApplePayOptionsTest : XCTestCase

@end

@implementation AWXApplePayOptionsTest

- (void)testInitWithMerchantIdentifier
{
    NSString *identifier = @"merchantIdentifier";
    AWXApplePayOptions *options = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:identifier];
    
    XCTAssertEqualObjects(options.merchantIdentifier, identifier);
    XCTAssertEqual(options.shippingType, PKShippingTypeShipping);
    XCTAssertEqualObjects(options.requiredBillingContactFields, [NSSet new]);
    XCTAssertEqualObjects(options.requiredShippingContactFields, [NSSet new]);
    XCTAssertNil(options.totalPriceLabel);
    XCTAssertNil(options.supportedCountries);
    XCTAssertNil(options.shippingMethods);
    XCTAssertNil(options.shippingContact);
    XCTAssertNil(options.billingContact);
}

@end
