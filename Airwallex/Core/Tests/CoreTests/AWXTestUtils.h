//
//  AWXTestUtils.h
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXTestUtils : NSObject

+ (nullable NSData *)dataFromJsonFile:(NSString *)filename;
+ (NSDictionary *)jsonNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
