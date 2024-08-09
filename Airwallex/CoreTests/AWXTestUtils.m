//
//  AWXTestUtils.m
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXTestUtils.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif
@implementation AWXTestUtils

+ (NSBundle *)testBundle {
    return [NSBundle bundleForClass:[AWXTestUtils class]];
}

+ (nullable NSData *)dataFromJsonFile:(NSString *)filename {
    NSBundle *bundle = [self testBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];

    if (!path) {
        return nil;
    }

    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

    if (!jsonString) {
        return nil;
    }

    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)jsonNamed:(NSString *)name {
    NSData *data = [self dataFromJsonFile:name];
    if (data != nil) {
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    return nil;
}

@end
