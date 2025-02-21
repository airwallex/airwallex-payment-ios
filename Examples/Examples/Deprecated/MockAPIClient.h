//
//  APIClient.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWXPaymentIntent;

NS_ASSUME_NONNULL_BEGIN

@interface MockAPIClient : NSObject

@property (nonatomic, readonly) NSURL *paymentBaseURL;
@property (nonatomic, strong, nullable) NSString *apiKey;
@property (nonatomic, strong, nullable) NSString *clientID;
@property (nonatomic, strong, nullable) NSString *token;

+ (instancetype)sharedClient;

- (void)createAuthenticationTokenWithCompletionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler;

- (void)createPaymentIntentWithParameters:(NSDictionary *)parameters
                        completionHandler:(void (^)(AWXPaymentIntent *_Nullable paymentIntent, NSError *_Nullable error))completionHandler;

- (void)createCustomerWithParameters:(NSDictionary *)parameters
                   completionHandler:(void (^)(NSDictionary *_Nullable result, NSError *_Nullable error))completionHandler;

- (void)generateClientSecretWithCustomerId:(NSString *)Id
                         completionHandler:(void (^)(NSDictionary *_Nullable result, NSError *_Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
