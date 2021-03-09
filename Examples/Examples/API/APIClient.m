//
//  APIClient.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "APIClient.h"
#import <Airwallex/Airwallex.h>

@implementation APIClient

+ (instancetype)sharedClient
{
    static APIClient *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [self new];
    });
    return sharedClient;
}

- (void)setPaymentBaseURL:(NSURL *)paymentBaseURL
{
    _paymentBaseURL = [paymentBaseURL URLByAppendingPathComponent:@""];
}

- (void)createAuthenticationTokenWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler
{
    NSURL *requestURL = [NSURL URLWithString:@"api/v1/authentication/login" relativeToURL:self.paymentBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.clientID forHTTPHeaderField:@"x-client-id"];
    [request setValue:self.apiKey forHTTPHeaderField:@"x-api-key"];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(error);
            });
            return;
        }
        
        NSError *anError;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&anError];
            NSString *errorMessage = json[@"error"];
            if (errorMessage) {
                anError = [NSError errorWithDomain:@"com.airwallex.paymentacceptance" code:-1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            }
            self.token = json[@"token"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(anError);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(anError);
        });
    }] resume];
}

- (void)createPaymentIntentWithParameters:(NSDictionary *)parameters
                        completionHandler:(void (^)(AWXPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error))completionHandler
{
    NSURL *requestURL = [NSURL URLWithString:@"api/v1/pa/payment_intents/create" relativeToURL:self.paymentBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (self.token) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    }
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        NSError *anError;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&anError];
            NSString *errorMessage = json[@"message"];
            if (errorMessage) {
                anError = [NSError errorWithDomain:@"com.airwallex.paymentacceptance" code:-1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            }
            
            AWXPaymentIntent *paymentIntent = [AWXPaymentIntent decodeFromJSON:json];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(paymentIntent, anError);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, anError);
        });
    }] resume];
}

- (void)createCustomerWithParameters:(NSDictionary *)parameters
                   completionHandler:(void (^)(NSDictionary * _Nullable result, NSError * _Nullable error))completionHandler
{
    NSURL *requestURL = [NSURL URLWithString:@"api/v1/pa/customers/create" relativeToURL:self.paymentBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (self.token) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    }
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        NSError *anError;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&anError];
            NSString *errorMessage = json[@"message"];
            if (errorMessage) {
                anError = [NSError errorWithDomain:@"com.airwallex.paymentacceptance" code:-1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(json, anError);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, anError);
        });
    }] resume];
}

- (void)createCustomerSecretWithId:(NSString *)Id
                 completionHandler:(void (^)(NSDictionary * _Nullable result, NSError * _Nullable error))completionHandler
{
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"api/v1/pa/customers/%@/generate_client_secret", Id] relativeToURL:self.paymentBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (self.token) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    }
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        NSError *anError;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&anError];
            NSString *errorMessage = json[@"message"];
            if (errorMessage) {
                anError = [NSError errorWithDomain:@"com.airwallex.paymentacceptance" code:-1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(json, anError);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, anError);
        });
    }] resume];
}

@end
