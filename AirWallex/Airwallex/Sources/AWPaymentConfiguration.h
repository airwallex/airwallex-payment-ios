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

@protocol AWPaymentResultDelegate <NSObject>

- (void)paymentDidFinishWithStatus:(AWPaymentStatus)status error:(nullable NSError *)error;
- (void)paymentWithWechatPaySDK:(AWWechatPaySDKResponse *)response;

@end

@interface AWPaymentConfiguration : NSObject <NSCopying>

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *intentId;
@property (nonatomic, copy) NSDecimalNumber *totalNumber;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy, nullable) NSString *customerId;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) AWBilling *shipping;
@property (nonatomic, weak) id <AWPaymentResultDelegate> delegate;

+ (instancetype)sharedConfiguration;
- (void)cache:(NSString *)key value:(NSString *)value;
- (NSString *)cacheWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
