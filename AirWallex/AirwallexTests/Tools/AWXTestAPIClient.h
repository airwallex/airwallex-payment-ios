//
//  AWXTestAPIClient.h
//  AirwallexTests
//
//  Created by Victor Zhu on 2020/4/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXPaymentIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXTestAPIClient : NSObject

@property (nonatomic, strong) NSURL *authBaseURL;
@property (nonatomic, strong) NSURL *paymentBaseURL;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *token;

+ (instancetype)sharedClient;

- (void)createAuthenticationTokenWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler;
- (void)createPaymentIntentWithParameters:(NSDictionary *)parameters
                        completionHandler:(void (^ _Nullable)(AWXPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
