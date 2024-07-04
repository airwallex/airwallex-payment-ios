//
//  APIClient.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWXPaymentIntent;
@class AWXGetPaymentMethodTypesResponse;

NS_ASSUME_NONNULL_BEGIN

@interface APIClient : NSObject

@property (nonatomic, readonly) NSURL *paymentBaseURL;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *token;

+ (instancetype)sharedClient;

- (void)createAuthenticationTokenWithCompletionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler;

- (void)createPaymentIntentWithParameters:(NSDictionary *)parameters
                        completionHandler:(void (^)(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error))completionHandler;

- (void)createCustomerWithParameters:(NSDictionary *)parameters
                   completionHandler:(void (^)(NSDictionary *_Nullable result, NSError *_Nullable error))completionHandler;

- (void)generateClientSecretWithCustomerId:(NSString *)Id
                         completionHandler:(void (^)(NSDictionary *_Nullable result, NSError *_Nullable error))completionHandler;

- (void)getPaymentMethodTypes:(NSString *)Id
                         completionHandler:(void (^)(AWXGetPaymentMethodTypesResponse *_Nullable response, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
