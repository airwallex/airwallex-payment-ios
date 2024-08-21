//
//  AWXPaymentMethodListViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPageViewTrackable.h"
#import "AWXPaymentMethodListViewModel.h"
#import "AWXViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXPaymentMethodListViewController` provides a list of payment method.
 */
@interface AWXPaymentMethodListViewController : AWXViewController<AWXPageViewTrackable>

@property (nonatomic, strong) AWXPaymentMethodListViewModel *viewModel;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithIsFlowFromPushing:(BOOL)isFlowFromPushing;

@end

NS_ASSUME_NONNULL_END
