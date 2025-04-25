//
//  NSDataBase64Test.m
//  CoreTests
//
//  Created by Hector.Huang on 2023/4/7.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "NSData+Base64.h"
#import <XCTest/XCTest.h>

@interface NSDataBase64Test : XCTestCase

@end

@implementation NSDataBase64Test

- (void)testInitWithBase64NoPaddingString {
    NSString *base64String = @"a.eyJ0eXBlIjoiY2xpZW50LXNlY3JldCIsInBhZGMiOiJISyIsImFjY291bnRfaWQiOiI1YTFkNjAyMi0yZmJiLTRhNWUtYTQyOC1kM2FlOGEyNmExMjMiLCJidXNpbmVzc19uYW1lIjoiRGVtbyBmb3IifQ";
    NSData *data = [NSData initWithBase64NoPaddingString:base64String];
    XCTAssertEqualObjects(data, [[NSData alloc] initWithBase64EncodedString:[base64String stringByAppendingString:@"=="] options:0]);
}

@end
