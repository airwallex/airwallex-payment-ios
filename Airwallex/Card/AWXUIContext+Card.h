//
//  AWXUIContext+Card.h
//  AirwallexPaymentSDK
//
//  Created by Weiping Li on 2024/11/27.
//

#import "AWXUIContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXUIContext (Card)

/// Present the card payment flow.
- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes NS_SWIFT_NAME(presentCardPaymentFlow(from:cardSchemes:)) __deprecated_msg("Use launchPayment(from:style:) in AWXUIContext+Extensions.swift within the Payment Module instead.");

/// Push the card payment flow.
- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes NS_SWIFT_NAME(pushCardPaymentFlow(from:cardSchemes:)) __deprecated_msg("Use launchPayment(from:style:) in AWXUIContext+Extensions.swift within the Payment Module instead.");

- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController NS_SWIFT_NAME(presentCardPaymentFlow(from:)) __deprecated_msg("Use launchPayment(from:style:) in AWXUIContext+Extensions.swift within the Payment Module instead.");

- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController NS_SWIFT_NAME(pushCardPaymentFlowFrom(from:)) __deprecated_msg("Use launchPayment(from:style:) in AWXUIContext+Extensions.swift within the Payment Module instead.");

@end

NS_ASSUME_NONNULL_END
