//
//  AWCardViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWCardViewController, AWPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

@protocol AWCardViewControllerDelegate <NSObject>

- (void)cardViewController:(AWCardViewController *)controller didCreatePaymentMethod:(AWPaymentMethod *)paymentMethod;

@end

@interface AWCardViewController : UIViewController

@property (nonatomic, weak) id <AWCardViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
