//
//  AWTestUtils.h
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/3/30.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWTestUtils : NSObject

+ (NSDictionary *)jsonNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
