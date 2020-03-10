//
//  AWPaymentUI.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWPaymentListViewController, AWCardViewController, AWPaymentViewController, AWEditShippingViewController;

NS_ASSUME_NONNULL_BEGIN

@interface AWPaymentUI : NSObject

+ (UINavigationController *)paymentMethodListNavigationController;
+ (UINavigationController *)newCardNavigationController;
+ (UINavigationController *)paymentDetailNavigationController;
+ (UINavigationController *)shippingNavigationController;

@end

NS_ASSUME_NONNULL_END
