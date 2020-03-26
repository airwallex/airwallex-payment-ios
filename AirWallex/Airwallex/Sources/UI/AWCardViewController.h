//
//  AWCardViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

@class AWCardViewController, AWPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles card creation.
 */
@protocol AWCardViewControllerDelegate <NSObject>

/**
 This method is called when a card has been created and saved to backend.

 @param controller The new card view controller.
 @param paymentMethod The saved card.
 */
- (void)cardViewController:(AWCardViewController *)controller didCreatePaymentMethod:(AWPaymentMethod *)paymentMethod;

@end

/**
 `AWCardViewController` provides a form to create card
 */
@interface AWCardViewController : AWViewController

/**
 A delegate which handles saved card.
 */
@property (nonatomic, weak) id <AWCardViewControllerDelegate> delegate;

/**
 A boolean which can switch to billing form
 */
@property (nonatomic) BOOL sameAsShipping;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
