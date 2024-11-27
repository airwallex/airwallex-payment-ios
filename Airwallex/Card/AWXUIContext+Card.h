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
- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes;

/// Push the card payment flow.
- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController cardSchemes:(NSArray<AWXCardBrand> *)cardSchemes;

- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController;

- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController;

@end

NS_ASSUME_NONNULL_END
