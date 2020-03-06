//
//  APIClient.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIClient : NSObject

+ (instancetype)sharedClient;

- (void)createAuthenticationToken:(NSURL *)url
                         clientId:(NSString *)clientId
                           apiKey:(NSString *)apiKey
                completionHandler:(void (^ _Nullable)(NSString * _Nullable token, NSError * _Nullable error))completionHandler;

- (void)createPaymentIntent:(NSURL *)url
                      token:(NSString *)token
                 parameters:(NSDictionary *)parameters
          completionHandler:(void (^ _Nullable)(NSDictionary * _Nullable result, NSError * _Nullable error))completionHandler;

- (void)createCustomer:(NSURL *)url
                 token:(NSString *)token
            parameters:(NSDictionary *)parameters
     completionHandler:(void (^ _Nullable)(NSDictionary * _Nullable result, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
