//
//  AWXPaymentMethodOptions.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXThreeDs` includes the information of 3ds.
 */
@interface AWXThreeDs : NSObject <AWXJSONEncodable>

/**
 Three domain request.
 */
@property (nonatomic, copy, nullable) NSString *paRes;

/**
 Return url.
 */
@property (nonatomic, copy, nullable) NSString *returnURL;

/**
 Attempt ID.
 */
@property (nonatomic, copy, nullable) NSString *attemptId;

/**
 Device data collection response.
 */
@property (nonatomic, copy, nullable) NSString *deviceDataCollectionRes;

/**
 3DS transaction ID.
 */
@property (nonatomic, copy, nullable) NSString *dsTransactionId;

@end

/**
 `AWXCardOptions` includes the options of card.
 */
@interface AWXCardOptions : NSObject <AWXJSONEncodable>

/**
 Should capture automatically when confirm. Default to false. The payment intent will be captured automatically if it is true, and authorized only if it is false.
 */
@property (nonatomic) BOOL autoCapture;

/**
 ThreeDs object.
 */
@property (nonatomic, strong, nullable) AWXThreeDs *threeDs;

@end

/**
 `AWXPaymentMethodOptions` includes the information of payment method options
 */
@interface AWXPaymentMethodOptions : NSObject <AWXJSONEncodable>

/**
 The options for card.
 */
@property (nonatomic, strong, nullable) AWXCardOptions *cardOptions;

@end

NS_ASSUME_NONNULL_END
