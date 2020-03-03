//
//  AWPaymentViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

@class AWPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

@interface AWPaymentViewController : AWViewController

@property (strong, nonatomic) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
