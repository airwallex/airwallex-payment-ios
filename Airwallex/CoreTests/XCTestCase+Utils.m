//
//  XCTestCase+Utils.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/4/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "CoreTests-Swift.h"
#import "XCTestCase+Utils.h"

@implementation XCTestCase (Utils)

- (void)waitForDuration:(NSTimeInterval)duration {
    XCTestExpectation *waitExpectation = [[XCTestExpectation alloc] initWithDescription:@"Waiting"];
    NSTimeInterval when = DISPATCH_TIME_NOW + duration;
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [waitExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:duration handler:nil];
}

- (void)waitForElement:(XCUIElement *)element duration:(NSTimeInterval)duration {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exists == YES"];
    [self expectationForPredicate:predicate evaluatedWithObject:element handler:nil];
    [self waitForExpectationsWithTimeout:duration handler:nil];
}

@end
