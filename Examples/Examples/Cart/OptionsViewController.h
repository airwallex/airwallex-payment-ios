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
static NSString * const kCachedCheckoutMode = @"kCachedCheckoutMode";
static NSString * const kCachedNextTriggerBy = @"kCachedNextTriggerBy";

typedef NS_ENUM(NSInteger, AirwallexCheckoutMode) {
    AirwallexCheckoutOneOffMode,
    AirwallexCheckoutRecurringMode,
    AirwallexCheckoutRecurringWithIntentMode
};

@interface OptionsViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
