//
//  AWXPaymentFormViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPageViewTrackable.h"
#import "AWXPaymentMethod.h"
#import "AWXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXPaymentFormViewController, AWXPaymentFormViewModel;

/**
 A delegate handles payment form result.
 */
@protocol AWXPaymentFormViewControllerDelegate<NSObject>

@optional
- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController
           didUpdatePaymentMethod:(AWXPaymentMethod *)paymentMethod;
- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController
          didConfirmPaymentMethod:(AWXPaymentMethod *)paymentMethod;

/// temporary solution, used by
/// only AWXOptionView will trigger this delegate callback
/// will be called before `paymentFormViewController:didUpdatePaymentMethod:`
/// - Parameters:
///   - paymentFormViewController: controller
///   - optionKey: key for the selected option
- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController
                  didSelectOption:(NSString *)optionKey;

@end

@class AWXPaymentMethod, AWXFormMapping;

/**
 `AWXPaymentFormViewController` handles payment form.
 */
@interface AWXPaymentFormViewController : AWXViewController<AWXPageViewTrackable>

@property (nonatomic, strong) AWXPaymentFormViewModel *viewModel;

/**
 A delegate which handles the result of payment form.
 */
@property (nonatomic, weak) id<AWXPaymentFormViewControllerDelegate> delegate;

/**
 Payment method.
 */
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;

/**
 Form mapping which render the UI of payment form.
 */
@property (nonatomic, strong) AWXFormMapping *formMapping;

@end

NS_ASSUME_NONNULL_END
