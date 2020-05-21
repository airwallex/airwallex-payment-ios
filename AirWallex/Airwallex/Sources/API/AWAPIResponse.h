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

/**
 An `AWAPIErrorResponse` includes error details.
 */
@interface AWAPIErrorResponse : NSObject <AWResponseProtocol>

/**
 Error message.
 */
@property (nonatomic, copy, readonly) NSString *message;

/**
 Error code.
 */
@property (nonatomic, copy, readonly) NSString *code;

/**
 Error object.
 */
@property (nonatomic, strong, readonly) NSError *error;

/**
 Initializer.
 
 @param message Error message.
 @param code Error code.
 @return The initialized error object.
 */
- (instancetype)initWithMessage:(NSString *)message
                           code:(NSString *)code;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
