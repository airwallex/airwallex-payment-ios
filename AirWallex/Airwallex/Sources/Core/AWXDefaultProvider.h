//
//  AWXDefaultProvider.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/22.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWXViewModel.h"
#import "AWXPaymentMethod.h"

@class AWXDefaultProvider;

NS_ASSUME_NONNULL_BEGIN

@protocol AWXProviderDelegate <NSObject>

@optional
- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss;

@end

@interface AWXDefaultProvider : NSObject

@property (nonatomic, weak, readonly) id <AWXProviderDelegate> delegate;
@property (nonatomic, readonly) AWXViewModel *viewModel;
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate viewModel:(AWXViewModel *)viewModel paymentMethod:(AWXPaymentMethod *)paymentMethod;

- (void)handleFlow;

@end

NS_ASSUME_NONNULL_END
