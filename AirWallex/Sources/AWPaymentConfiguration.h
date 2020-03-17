//
//  AWPaymentConfiguration.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWBilling, AWConfirmPaymentIntentResponse, AWWechatPaySDKResponse;

typedef NS_ENUM(NSUInteger, AWPaymentStatus) {
    AWPaymentStatusSuccess,
    AWPaymentStatusError,
};

NS_ASSUME_NONNULL_BEGIN

@protocol AWPaymentResultDelegate <NSObject>

- (void)paymentDidFinishWithStatus:(AWPaymentStatus)status error:(nullable NSError *)error;
- (void)paymentWithWechatPaySDK:(AWWechatPaySDKResponse *)response;

@end

@interface AWPaymentConfiguration : NSObject

@property (nonatomic, copy, readwrite) NSString *baseURL;
@property (nonatomic, copy, readwrite) NSString *intentId;
@property (nonatomic, copy, readwrite) NSDecimalNumber *totalNumber;
@property (nonatomic, copy, readwrite) NSString *token;
@property (nonatomic, copy, readwrite) NSString *clientSecret;
@property (nonatomic, copy, readwrite, nullable) NSString *customerId;
@property (nonatomic, copy, readwrite) NSString *currency;
@property (nonatomic, strong) AWBilling *shipping;
@property (nonatomic, weak) id <AWPaymentResultDelegate> delegate;

+ (instancetype)sharedConfiguration;
- (void)cache:(NSString *)key value:(NSString *)value;
- (NSString *)cacheWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
