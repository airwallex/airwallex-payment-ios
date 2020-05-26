//
//  AWPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"
#import "AWPaymentMethod.h"
#import "AWResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class AWConfirmPaymentNextAction, AWPaymentAttempt;

/**
 `AWConfirmPaymentIntentResponse` includes the result of payment flow.
 */
@interface AWConfirmPaymentIntentResponse : NSObject <AWResponseProtocol>

/**
 Payment status.
 */
@property (nonatomic, readonly) NSString *status;

/**
 Next action.
 */
@property (nonatomic, readonly, nullable) AWConfirmPaymentNextAction *nextAction;

/**
 The latest payment attempt object.
 */
@property (nonatomic, readonly, nullable) AWPaymentAttempt *latestPaymentAttempt;

@end

@class AWWeChatPaySDKResponse, AWRedirectResponse;

/**
 `AWConfirmPaymentNextAction` includes the parameters for next action.
 */
@interface AWConfirmPaymentNextAction : NSObject <AWJSONDecodable>

/**
 Next action type.
 */
@property (nonatomic, readonly) NSString *type;

/**
 The parameters for WeChatSDK.
 */
@property (nonatomic, readonly, nullable) AWWeChatPaySDKResponse *weChatPayResponse;

/**
 The parameters for redirection.
 */
@property (nonatomic, readonly, nullable) AWRedirectResponse *redirectResponse;

@end

/**
 `AWWeChatPaySDKResponse` includes the parameters for WeChatSDK.
 */
@interface AWWeChatPaySDKResponse: NSObject <AWJSONDecodable>

@property (nonatomic, readonly, nullable) NSString *appId;
@property (nonatomic, readonly) NSString *timeStamp;
@property (nonatomic, readonly) NSString *nonceStr;
@property (nonatomic, readonly) NSString *prepayId;
@property (nonatomic, readonly) NSString *partnerId;
@property (nonatomic, readonly) NSString *package;
@property (nonatomic, readonly) NSString *sign;

@end

/**
 `AWRedirectResponse` includes the parameters for redirection.
 */
@interface AWRedirectResponse : NSObject <AWJSONDecodable>

@property (nonatomic, readonly) NSString *jwt;
@property (nonatomic, readonly) NSString *stage;
@property (nonatomic, readonly, nullable) NSString *acs;
@property (nonatomic, readonly, nullable) NSString *xid;
@property (nonatomic, readonly, nullable) NSString *req;

@end

/**
 `AWAuthenticationData` includes the parameters for 3ds authentication.
 */
@interface AWAuthenticationData : NSObject <AWJSONDecodable>

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) NSString *score;
@property (nonatomic, readonly) NSString *version;

/**
 Check whether 3ds version is v2.x.
 */
- (BOOL)isThreeDSVersion2;

@end

/**
 `AWPaymentAttempt` includes the information of payment attempt.
 */
@interface AWPaymentAttempt : NSObject <AWJSONDecodable>

/**
 Attempt id.
 */
@property (nonatomic, readonly) NSString *Id;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSNumber *amount;

/**
 Payment method.
 */
@property (nonatomic, readonly) AWPaymentMethod *paymentMethod;

/**
 The status of payment attempt
 */
@property (nonatomic, readonly) NSString *status;

/**
 Captured amount.
 */
@property (nonatomic, readonly) NSNumber *capturedAmount;

/**
 Refunded amount.
 */
@property (nonatomic, readonly) NSNumber *refundedAmount;

/**
 3DS authentication data.
 */
@property (nonatomic, readonly) AWAuthenticationData *authenticationData;

@end

/**
 `AWGetPaymentIntentResponse` includes the information of payment intent.
 */
@interface AWGetPaymentIntentResponse : NSObject <AWResponseProtocol>

/**
 Intent id.
 */
@property (nonatomic, readonly) NSString *Id;

/**
 Request id.
 */
@property (nonatomic, readonly) NSString *requestId;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSNumber *amount;

/**
 Currency.
 */
@property (nonatomic, readonly) NSString *currency;

/**
 Merchant order id.
 */
@property (nonatomic, readonly) NSString *merchantOrderId;

/**
 Order data.
 */
@property (nonatomic, readonly) NSDictionary *order;

/**
 Customer id.
 */
@property (nonatomic, readonly) NSString *customerId;

/**
 Payment status.
 */
@property (nonatomic, readonly) NSString *status;

/**
 Captured amount.
 */
@property (nonatomic, readonly) NSNumber *capturedAmount;

/**
 Created date.
 */
@property (nonatomic, readonly) NSString *createdAt;

/**
 Updated date.
 */
@property (nonatomic, readonly) NSString *updatedAt;

/**
 Available payment method types.
 */
@property (nonatomic, readonly) NSArray <NSString *> *availablePaymentMethodTypes;

/**
 Client secret.
 */
@property (nonatomic, readonly) NSString *clientSecret;

@end

NS_ASSUME_NONNULL_END
