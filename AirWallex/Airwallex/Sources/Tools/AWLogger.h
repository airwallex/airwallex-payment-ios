//
//  AWLogger.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWLogger : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@property (nonatomic) BOOL enableLogPrinted;
@property (class, nonatomic, readonly, strong) AWLogger *sharedLogger;

- (void)logException:(NSString *)message;
- (void)logEvent:(NSString *)name;
- (void)logEvent:(NSString *)name parameters:(NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
