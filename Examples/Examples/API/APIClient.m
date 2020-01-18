//
//  APIClient.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "APIClient.h"

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

- (void)createAuthenticationToken:(NSURL *)url clientId:(NSString *)clientId apiKey:(NSString *)apiKey completionHandler:(void (^)(NSString * _Nullable token, NSError * _Nullable error))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:clientId forHTTPHeaderField:@"x-client-id"];
    [request setValue:apiKey forHTTPHeaderField:@"x-api-key"];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }

        NSError *anError;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&anError];
            NSString *token = json[@"token"];

            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(token, anError);
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, anError);
        });
    }] resume];
}

- (void)createPaymentIntent:(NSURL *)url token:(NSString *)token parameters:(NSDictionary *)parameters completionHandler:(void (^ _Nullable)(NSDictionary * _Nullable result, NSError * _Nullable error))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }

        NSError *anError;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&anError];
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
