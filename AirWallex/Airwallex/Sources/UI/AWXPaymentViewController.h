//
//  AWXPaymentViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXViewController.h"
#import "AWXUIContext.h"

@class AWXPaymentIntent, AWXPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXPaymentViewController` provides a confirm button for user to finish checkout flow.
 */
@interface AWXPaymentViewController : AWXViewController

/**
 A delegate which handles confirmed payment intent.
 */
@property (nonatomic, weak) id <AWXPaymentResultDelegate> delegate;

/**
 A payment method has been selected.
 */
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;

/**
 A payment intent.
 */
@property (nonatomic, strong) AWXPaymentIntent *paymentIntent;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END