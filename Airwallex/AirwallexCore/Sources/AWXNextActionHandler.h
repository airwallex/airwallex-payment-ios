//
//  AWXNextActionHandler.h
//  Airwallex
//
//  Created by Hector.Huang on 2024/3/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXNextActionHandler : NSObject

/// Previously used/generated payment consent
@property (nonatomic, strong, nullable) AWXPaymentConsent *paymentConsent;

- (instancetype)initWithDelegate:(id<AWXProviderDelegate>)delegate session:(AWXSession *)session;

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction;

@end

NS_ASSUME_NONNULL_END
