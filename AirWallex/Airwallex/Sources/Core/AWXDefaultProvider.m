//
//  AWXDefaultProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/22.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"

@interface AWXDefaultProvider ()

@property (nonatomic, weak, readwrite) id <AWXProviderDelegate> delegate;
@property (nonatomic, strong, readwrite) AWXViewModel *viewModel;
@property (nonatomic, strong, readwrite) AWXPaymentMethod *paymentMethod;

@end

@implementation AWXDefaultProvider

- (instancetype)initWithDelegate:(id <AWXProviderDelegate>)delegate viewModel:(AWXViewModel *)viewModel paymentMethod:(AWXPaymentMethod *)paymentMethod
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _viewModel = viewModel;
        _paymentMethod = paymentMethod;
    }
    return self;
}

- (void)handleFlow
{
    [_viewModel confirmPaymentIntentWithPaymentMethod:_paymentMethod paymentConsent:nil];
}

@end
