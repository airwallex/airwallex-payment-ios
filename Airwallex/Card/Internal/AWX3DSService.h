//
//  AWX3DSService.h
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWX3DSService, AWXConfirmPaymentIntentResponse, AWXConfirmPaymentNextAction, AWXPaymentMethod, AWXDevice, AWXRedirectResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 A delegate which handles 3ds results.
 */
@protocol AWX3DSServiceDelegate<NSObject>

/**
 This method is called when the user has started the 3ds flow.

 @param service The service handling 3ds flow.
 @param controller The webview controller.
 */
- (void)threeDSService:(AWX3DSService *)service shouldPresentViewController:(UIViewController *)controller;

/**
 This method is called when the user needs to go through 3ds flow.

 @param service The service handling 3ds flow.
 @param controller The webview controller.
 */
- (void)threeDSService:(AWX3DSService *)service shouldInsertViewController:(UIViewController *)controller;

/**
 This method is called when the user has completed the 3ds flow.

 @param service The service handling 3ds flow.
 @param response The response of 3ds auth.
 @param error The error if 3ds auth failed.
 */
- (void)threeDSService:(AWX3DSService *)service
    didFinishWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                    error:(nullable NSError *)error;

@end

@interface AWX3DSService : NSObject

/**
 Customer id.
 */
@property (nonatomic, copy) NSString *intentId, *customerId;

/**
 Device object. (Get by calling `AWXSecurityService` method)
 */
@property (nonatomic, strong) AWXDevice *device;

/**
 The delegate which handles 3ds result.
 */
@property (nonatomic, weak) id<AWX3DSServiceDelegate> delegate;

/**
 Present the 3ds flow.
 */
- (void)present3DSFlowWithNextAction:(AWXConfirmPaymentNextAction *)nextAction;

+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
