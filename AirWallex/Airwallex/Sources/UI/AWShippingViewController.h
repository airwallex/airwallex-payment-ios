//
//  AWShippingViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

@class AWPlaceDetails, AWShippingViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles selected shipping.
 */
@protocol AWShippingViewControllerDelegate <NSObject>

/**
 This method is called when a shipping has been saved.
 
 @param controller The shipping view controller.
 @param shipping The selected shipping.
 */
- (void)shippingViewController:(AWShippingViewController *)controller didEditShipping:(AWPlaceDetails *)shipping;

@end

/**
 `AWShippingViewController` provides a form to edit shipping address.
 */
@interface AWShippingViewController : AWViewController

/**
 A delegate which handles saved shipping.
 */
@property (nonatomic, weak) id <AWShippingViewControllerDelegate> delegate;

/**
 Saved shippping.
 */
@property (nonatomic, strong, nullable) AWPlaceDetails *shipping;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
