//
//  AWXPaymentFormViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Airwallex/Airwallex.h>

NS_ASSUME_NONNULL_BEGIN

@class AWXFormMapping;
@interface AWXPaymentFormViewController : AWXViewController

@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;
@property (nonatomic, strong) AWXFormMapping *formMapping;

@end

NS_ASSUME_NONNULL_END
