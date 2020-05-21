//
//  AWThreeDSService.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWThreeDSService, AWConfirmPaymentIntentResponse, AWPaymentMethod, AWDevice, AWRedirectResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol AWThreeDSServiceDelegate <NSObject>

- (void)threeDSService:(AWThreeDSService *)service
 didFinishWithResponse:(nullable AWConfirmPaymentIntentResponse *)response
                 error:(nullable NSError *)error;

@end

@interface AWThreeDSService : NSObject

@property (nonatomic, copy) NSString *intentId, *customerId;
@property (nonatomic, strong) AWPaymentMethod *paymentMethod;
@property (nonatomic, strong) AWDevice *device;
@property (nonatomic, weak) UIViewController *presentingViewController;
@property (nonatomic, weak) id <AWThreeDSServiceDelegate> delegate;

- (void)presentThreeDSFlowWithServerJwt:(NSString *)serverJwt;

+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
