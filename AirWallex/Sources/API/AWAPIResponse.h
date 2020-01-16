//
//  AWAPIResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWAPIErrorResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSNumber *statusCode;

- (instancetype)initWithMessage:(NSString *)message
                           code:(NSString *)code
                           type:(NSString *)type
                     statusCode:(NSNumber *)statusCode;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
