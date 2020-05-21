//
//  AWPaymentMethodOptions.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWThreeDs : NSObject <AWJSONEncodable>

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

@interface AWCardOptions : NSObject <AWJSONEncodable>

/**
 Should capture automatically when confirm. Default to false. The payment intent will be captured automatically if it is true, and authorized only if it is false.
 */
@property (nonatomic) BOOL autoCapture;

/**
 ThreeDs object.
 */
@property (nonatomic, strong, nullable) AWThreeDs *threeDs;

@end

/**
 `AWPaymentMethodOptions` includes the information of payment method options
 */
@interface AWPaymentMethodOptions : NSObject <AWJSONEncodable>

/**
 The options for card.
 */
@property (nonatomic, strong, nullable) AWCardOptions *cardOptions;

@end

NS_ASSUME_NONNULL_END
