//
//  AWXUtilsTest.m
//  CoreTests
//
//  Created by Hector.Huang on 2023/4/7.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXUtils.h"
#import <XCTest/XCTest.h>

@interface AWXUtilsTest : XCTestCase

@end

@implementation AWXUtilsTest

- (void)testStringByInsertingBetweenWordsWithString {
    NSString *test = @"GetPaymentMethods";
    XCTAssertEqualObjects([test stringByInsertingBetweenWordsWithString:@"-"], @"Get-Payment-Methods");
}

@end
