//
//  AWXUIContext+Card.h
//  AirWallexPaymentSDK
//
//  Created by Weiping Li on 2024/11/27.
//

#import "AWXUIContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXUIContext (Card)

/// Present the card payment flow.
- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes NS_SWIFT_NAME(presentCardPaymentFlow(from:cardScheme:));

/// Push the card payment flow.
- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes NS_SWIFT_NAME(pushCardPaymentFlow(from:cardScheme:));

- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController NS_SWIFT_NAME(presentCardPaymentFlow(from:));

- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController NS_SWIFT_NAME(pushCardPaymentFlowFrom(from:));

@end

NS_ASSUME_NONNULL_END
