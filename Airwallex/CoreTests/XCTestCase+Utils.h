//
//  XCTestCase+Utils.h
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/4/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <XCTest/XCTest.h>

@class AWXPaymentIntent;

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (Utils)

- (void)waitForDuration:(NSTimeInterval)duration;
- (void)waitForElement:(XCUIElement *)element duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
