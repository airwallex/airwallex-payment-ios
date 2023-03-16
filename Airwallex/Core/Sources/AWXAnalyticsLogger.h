//
//  AWXAnalyticsLogger.h
//  Core
//
//  Created by Hector.Huang on 2023/3/14.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXAnalyticsLogger : NSObject

+ (instancetype)shared;

- (void)logWithEventName:(NSString *)eventName extraInfo:(NSDictionary<NSString *, id> *)extraInfo;

@end

NS_ASSUME_NONNULL_END
