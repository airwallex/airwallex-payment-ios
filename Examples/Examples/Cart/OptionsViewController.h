//
//  OptionsViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/3/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionsViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol OptionsViewControllerDelegate <NSObject>

- (void)optionsViewController:(OptionsViewController *)viewController didEditTotalAmount:(NSDecimalNumber *)totalAmount;
- (void)optionsViewController:(OptionsViewController *)viewController didEditCurrency:(NSString *)currency;

@end

@interface OptionsViewController : UIViewController

@property (weak, nonatomic) id <OptionsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
