//
//  NSBundle+ApplePay.m
//  ApplePay
//
//  Created by Weiping Li on 2025/3/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#import "AWXUtils.h"
#import "NSBundle+ApplePay.h"

@implementation NSBundle (ApplePay)

+ (nullable NSBundle *)applePayBundle {
    NSArray *resourceName = @[@"AirwallexApplePay", @"AirwallexPaymentSDK_AirwallexApplePay"];
    NSBundle *resourceBundle = nil;
    for (NSString *name in resourceName) {
        NSString *path = [self.sdkBundle pathForResource:name ofType:@"bundle"];
        if (path == nil)
            continue;
        resourceBundle = [NSBundle bundleWithPath:path];
        if (resourceBundle != nil)
            break;
    }
    return resourceBundle ? resourceBundle : self.sdkBundle;
}

@end
