//
//  AWXSecurityService.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXSecurityService` is a service to handle security information.
 */
@interface AWXSecurityService : NSObject

/**
 Convenience constructor for a security service.
 
 @return The shared security service.
 */
+ (instancetype)sharedService;

/**
 Request device id.
 */
- (void)doProfile:(NSString *)intentId
       completion:(void(^)(NSString * _Nullable))completion;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
