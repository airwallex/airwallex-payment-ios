//
//  AWXPaymentFormViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Airwallex/Airwallex.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXPaymentFormViewController : AWXViewController

@property (nonatomic, strong, nullable) AWXPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
