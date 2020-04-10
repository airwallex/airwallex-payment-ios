//
//  AWPaymentViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"
#import "AWUIContext.h"

@class AWPaymentIntent, AWPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWPaymentViewController` provides a confirm button for user to finish checkout flow.
 */
@interface AWPaymentViewController : AWViewController

/**
 A delegate which handles confirmed payment intent.
 */
@property (nonatomic, weak) id <AWPaymentResultDelegate> delegate;

/**
 A payment method has been selected.
 */
@property (nonatomic, strong) AWPaymentMethod *paymentMethod;

/**
 A payment intent.
 */
@property (nonatomic, strong) AWPaymentIntent *paymentIntent;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
