//
//  NSData+Base64.m
//  Core
//
//  Created by Hector.Huang on 2023/3/17.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "NSData+Base64.h"

@implementation NSData (Base64)

+ (instancetype)initWithBase64NoPaddingString:(NSString *)base64String {
    NSString *encodedString = base64String;
    NSInteger remainder = base64String.length % 4;
    if (remainder > 0) {
        encodedString = [base64String stringByPaddingToLength:base64String.length + 4 - remainder withString:@"=" startingAtIndex:0];
    }
    if (encodedString.length > 0) {
        return [[self alloc] initWithBase64EncodedString:encodedString options:0];
    }
    return nil;
}

@end
