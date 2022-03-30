//
//  AWXPaymentIntentSummaryTest.m
//  ApplePayTests
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AWXPaymentIntent+Summary.h"

@interface AWXPaymentIntentSummaryTest : XCTestCase

@end

@implementation AWXPaymentIntentSummaryTest

- (void)testPaymentSummaryItems
{
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithString:@"1234.5"];
    intent.amount = number;
    
    NSString *label = @"label";
    
    NSArray <PKPaymentSummaryItem *> *items = [intent paymentSummaryItemsWithTotalPriceLabel:label];
    
    XCTAssertEqual(items.count, 1);
    
    PKPaymentSummaryItem *item = items[0];
    
    XCTAssertEqualObjects(item.label, label);
    XCTAssertEqual(item.type, PKPaymentSummaryItemTypeFinal);
    XCTAssertEqualObjects(item.amount, number);
}

- (void)testPaymentSummaryItemsWithNoLabel
{
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    intent.amount = [[NSDecimalNumber alloc] initWithString:@"1234.5"];
    
    NSArray <PKPaymentSummaryItem *> *items = [intent paymentSummaryItemsWithTotalPriceLabel:nil];
    
    XCTAssertEqual(items.count, 1);
    
    PKPaymentSummaryItem *item = items[0];
    
    XCTAssertEqualObjects(item.label, @"");
}

@end
