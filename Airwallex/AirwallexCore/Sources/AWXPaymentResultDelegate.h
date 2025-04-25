//
//  AWXPaymentResultDelegate.h
//  AirwallexCore
//
//  Created by Weiping Li on 2025/4/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AWXPaymentResultDelegate<NSObject>

/**
 This method is called when the user has completed the checkout.

 @param controller The controller handling payment result. Could be nil for low level API integration or when user dismiss the payment view controller.
 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentViewController:(UIViewController *_Nullable)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error;

@optional

/**
 This method is called when the user has completed the checkout and payment consent id is produced.

 @param controller The controller handling payment result. Could be nil for low level API integration.
 @param paymentConsentId The id of payment consent.
 */
- (void)paymentViewController:(UIViewController *_Nullable)controller didCompleteWithPaymentConsentId:(NSString *)paymentConsentId;

@end

NS_ASSUME_NONNULL_END
