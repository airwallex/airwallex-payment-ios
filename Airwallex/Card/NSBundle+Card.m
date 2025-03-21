//
//  NSBundle+Card.m
//  WeChatPay
//
//  Created by Weiping Li on 2025/3/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#import "AWXUtils.h"
#import "NSBundle+Card.h"

@implementation NSBundle (Card)

+ (NSBundle *)cardBundle {
    NSArray *resourceName = @[@"AirwallexCard", @"AirwallexPaymentSDK_AirwallexCard"];
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
