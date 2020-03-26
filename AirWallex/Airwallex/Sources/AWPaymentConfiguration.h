//
//  AWPaymentConfiguration.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWBilling, AWWechatPaySDKResponse;

typedef NS_ENUM(NSUInteger, AWPaymentStatus) {
    AWPaymentStatusSuccess,
    AWPaymentStatusError,
};

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles checkout results.
 */
@protocol AWPaymentResultDelegate <NSObject>

/**
 This method is called when the user has completed the checkout.

 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentDidFinishWithStatus:(AWPaymentStatus)status error:(nullable NSError *)error;

/**
 This method is called when the user has completed the checkout with wechat pay.

 @param response The wechat object.
 */
- (void)paymentWithWechatPaySDK:(AWWechatPaySDKResponse *)response;

@end

/**
 An `AWPaymentConfiguration` is a set of merchant-specific Airwallex configuration settings.
 */
@interface AWPaymentConfiguration : NSObject <NSCopying>

/**
 The base URL for payment.
 */
@property (nonatomic, copy) NSURL *baseURL;

/**
 The intent ID for payment.
 */
@property (nonatomic, copy) NSString *intentId;

/**
 The total amount.
 */
@property (nonatomic, copy) NSDecimalNumber *totalAmount;

/**
 The token for auth.
 */
@property (nonatomic, copy) NSString *token;

/**
 The client secret for payment.
 */
@property (nonatomic, copy) NSString *clientSecret;

/**
 The customer ID.
 */
@property (nonatomic, copy, nullable) NSString *customerId;

/**
 The currency.
 */
@property (nonatomic, copy) NSString *currency;

/**
 The shipping object.
 */
@property (nonatomic, copy) AWBilling *shipping;

/**
 The delegate which handles checkout events.
 */
@property (nonatomic, weak) id <AWPaymentResultDelegate> delegate;

/**
 Convenience constructor for a configuration.

 @return The shared configuration.
 */
+ (instancetype)sharedConfiguration;

- (void)cache:(NSString *)key value:(NSString *)value;
- (NSString *)cacheWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
