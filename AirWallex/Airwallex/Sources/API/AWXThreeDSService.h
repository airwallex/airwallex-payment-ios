//
//  AWXThreeDSService.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWXThreeDSService, AWXConfirmPaymentIntentResponse, AWXPaymentMethod, AWXDevice, AWXRedirectResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles 3ds results.
 */
@protocol AWXThreeDSServiceDelegate <NSObject>

/**
 This method is called when the user has completed the 3ds flow.
 
 @param service The service handling 3ds flow.
 @param response The response of 3ds auth.
 @param error The error if 3ds auth failed.
 */
- (void)threeDSService:(AWXThreeDSService *)service
 didFinishWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                 error:(nullable NSError *)error;

@end

/**
 `AWXThreeDSService` is a service handles 3ds flow.
 */
@interface AWXThreeDSService : NSObject

/**
 Customer id.
 */
@property (nonatomic, copy) NSString *intentId, *customerId;

/**
 Payment method object.
 */
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;

/**
 Device object. (Get by calling `AWXSecurityService` method)
 */
@property (nonatomic, strong) AWXDevice *device;

/**
 The hostViewController will present or push the payment flow.
 */
@property (nonatomic, weak) UIViewController *presentingViewController;

/**
 The delegate which handles 3ds result.
 */
@property (nonatomic, weak) id <AWXThreeDSServiceDelegate> delegate;

/**
 Present the 3ds flow.
 */
- (void)presentThreeDSFlowWithServerJwt:(NSString *)serverJwt;
- (void)confirmWithReferenceId:(NSString *)referenceId;

+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
