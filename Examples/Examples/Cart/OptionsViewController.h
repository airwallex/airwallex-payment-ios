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

static NSString * const kCachedCustomerID = @"kCachedCustomerID";

@protocol OptionsViewControllerDelegate <NSObject>

- (void)optionsViewController:(OptionsViewController *)viewController didEditAmount:(NSDecimalNumber *)amount;
- (void)optionsViewController:(OptionsViewController *)viewController didEditCurrency:(NSString *)currency;

@end

@interface OptionsViewController : UIViewController

@property (weak, nonatomic) id <OptionsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) NSDecimalNumber *amount;

@end

NS_ASSUME_NONNULL_END
