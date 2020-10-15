//
//  AWXDCCViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/9/29.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Airwallex/Airwallex.h>

@class AWXDCCViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles selected payment currency.
 */
@protocol AWXDCCViewControllerDelegate <NSObject>

/**
 This method is called when a payment currency has been selected.

 @param controller The payment method list view controller.
 @param useDCC Use dcc to confirm payment.
 */
- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC;

@end

@interface AWXDCCViewController : AWXViewController

/**
 The response including currency data.
 */
@property (nonatomic, strong) AWXConfirmPaymentIntentResponse *response;

/**
 A delegate which handles confirm payment currency.
 */
@property (nonatomic, weak) id <AWXDCCViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
