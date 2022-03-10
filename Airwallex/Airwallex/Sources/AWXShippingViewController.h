//
//  AWXShippingViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXViewController.h"

@class AWXPlaceDetails, AWXShippingViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles selected shipping.
 */
@protocol AWXShippingViewControllerDelegate <NSObject>

/**
 This method is called when a shipping has been saved.
 
 @param controller The shipping view controller.
 @param shipping The selected shipping.
 */
- (void)shippingViewController:(AWXShippingViewController *)controller didEditShipping:(AWXPlaceDetails *)shipping;

@end

/**
 `AWXShippingViewController` provides a form to edit shipping address.
 */
@interface AWXShippingViewController : AWXViewController

/**
 A delegate which handles saved shipping.
 */
@property (nonatomic, weak) id <AWXShippingViewControllerDelegate> delegate;

/**
 Saved shippping.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *shipping;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
