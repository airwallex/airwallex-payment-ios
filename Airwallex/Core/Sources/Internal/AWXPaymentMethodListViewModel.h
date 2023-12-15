//
//  AWXPaymentMethodListViewModel.h
//  Core
//
//  Created by Hector.Huang on 2023/12/12.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXPaymentMethodListViewModel : NSObject

typedef void (^PaymentMethodsAndConsentsCompletionHandler)(NSArray<AWXPaymentMethodType *> *methods, NSArray<AWXPaymentConsent *> *consents, NSError *_Nullable error);

- (instancetype)initWithSession:(AWXSession *)session APIClient:(AWXAPIClient *)client;

- (void)fetchAvailablePaymentMethodsAndConsentsWithCompletionHandler:(PaymentMethodsAndConsentsCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
