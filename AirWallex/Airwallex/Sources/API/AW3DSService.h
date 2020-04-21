//
//  AW3DSService.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AWPaymentMethod, AWRedirectResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol AW3DSServiceDelegate <NSObject>

@end

@interface AW3DSService : NSObject

@property (nonatomic, copy) NSString *intentId, *customerId;
@property (nonatomic, strong) AWPaymentMethod *paymentMethod;
@property (nonatomic, weak) UIViewController *presentingViewController;
@property (nonatomic, weak) id <AW3DSServiceDelegate> delegate;

- (void)present3DSFlowWithRedirectResponse:(AWRedirectResponse *)response;

@end

NS_ASSUME_NONNULL_END
