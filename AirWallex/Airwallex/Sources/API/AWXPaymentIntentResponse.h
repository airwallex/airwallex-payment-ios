//
//  AWXPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"
#import "AWXPaymentMethod.h"
#import "AWXResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXConfirmPaymentNextAction, AWXPaymentAttempt;

/**
 `AWXConfirmPaymentIntentResponse` includes the result of payment flow.
 */
@interface AWXConfirmPaymentIntentResponse : NSObject <AWXResponseProtocol>

/**
 Currency.
 */
@property (nonatomic, readonly) NSString *currency;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *amount;

/**
 Payment status.
 */
@property (nonatomic, readonly) NSString *status;

/**
 Next action.
 */
@property (nonatomic, readonly, nullable) AWXConfirmPaymentNextAction *nextAction;

/**
 The latest payment attempt object.
 */
@property (nonatomic, readonly, nullable) AWXPaymentAttempt *latestPaymentAttempt;

@end

@class AWXWeChatPaySDKResponse, AWXRedirectResponse, AWXDccResponse;

/**
 `AWXConfirmPaymentNextAction` includes the parameters for next action.
 */
@interface AWXConfirmPaymentNextAction : NSObject <AWXJSONDecodable>

/**
 Next action type.
 */
@property (nonatomic, readonly) NSString *type;

/**
 The parameters for WeChatSDK.
 */
@property (nonatomic, readonly, nullable) AWXWeChatPaySDKResponse *weChatPayResponse;

/**
 The parameters for redirection.
 */
@property (nonatomic, readonly, nullable) AWXRedirectResponse *redirectResponse;

/**
  The parameters for dcc.
 */
@property (nonatomic, readonly, nullable) AWXDccResponse *dccResponse;

@end

/**
 `AWXWeChatPaySDKResponse` includes the parameters for WeChatSDK.
 */
@interface AWXWeChatPaySDKResponse: NSObject <AWXJSONDecodable>

@property (nonatomic, readonly, nullable) NSString *appId;
@property (nonatomic, readonly) NSString *timeStamp;
@property (nonatomic, readonly) NSString *nonceStr;
@property (nonatomic, readonly) NSString *prepayId;
@property (nonatomic, readonly) NSString *partnerId;
@property (nonatomic, readonly) NSString *package;
@property (nonatomic, readonly) NSString *sign;

@end

/**
 `AWXRedirectResponse` includes the parameters for redirection.
 */
@interface AWXRedirectResponse : NSObject <AWXJSONDecodable>

@property (nonatomic, readonly) NSString *jwt;
@property (nonatomic, readonly) NSString *stage;
@property (nonatomic, readonly, nullable) NSString *acs;
@property (nonatomic, readonly, nullable) NSString *xid;
@property (nonatomic, readonly, nullable) NSString *req;

@end

/**
 `AWXDccResponse` includes the parameters for dcc.
 */
@interface AWXDccResponse : NSObject <AWXJSONDecodable>

@property (nonatomic, readonly) NSString *currency;
@property (nonatomic, readonly) NSString *currencyPair;
@property (nonatomic, readonly) NSDecimalNumber *amount;
@property (nonatomic, readonly) NSDecimalNumber *clientRate;
@property (nonatomic, readonly) NSString *rateTimestamp, *rateExpiry;

@end

/**
 `AWXAuthenticationData` includes the parameters for 3ds authentication.
 */
@interface AWXAuthenticationData : NSObject <AWXJSONDecodable>

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) NSString *score;
@property (nonatomic, readonly) NSString *version;

/**
 Check whether 3ds version is v2.x.
 */
- (BOOL)isThreeDSVersion2;

@end

/**
 `AWXPaymentAttempt` includes the information of payment attempt.
 */
@interface AWXPaymentAttempt : NSObject <AWXJSONDecodable>

/**
 Attempt id.
 */
@property (nonatomic, readonly) NSString *Id;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *amount;

/**
 Payment method.
 */
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

/**
 The status of payment attempt
 */
@property (nonatomic, readonly) NSString *status;

/**
 Captured amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *capturedAmount;

/**
 Refunded amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *refundedAmount;

/**
 3DS authentication data.
 */
@property (nonatomic, readonly) AWXAuthenticationData *authenticationData;

@end

/**
 `AWXGetPaymentIntentResponse` includes the information of payment intent.
 */
@interface AWXGetPaymentIntentResponse : NSObject <AWXResponseProtocol>

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
@property (nonatomic, readonly) NSDecimalNumber *amount;

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
@property (nonatomic, readonly) NSDecimalNumber *capturedAmount;

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

@interface AWXGetPaResResponse : NSObject <AWXResponseProtocol>

/**
 PaRes
 */
@property (nonatomic, readonly) NSString *paRes;

@end

NS_ASSUME_NONNULL_END
