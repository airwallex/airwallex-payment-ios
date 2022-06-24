//
//  AWXTrackManager.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/4/8.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXTrackManager.h"
#import "AWXAPIClient.h"

@implementation AWXTrackManager

+ (instancetype)sharedTrackManager {
    static AWXTrackManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    return shared;
}

- (void)trackWithParameters:(NSDictionary *)parameters
          completionHandler:(void (^)(NSDictionary *_Nullable result, NSError *_Nullable error))completionHandler {
    NSURL *paymentBaseURL = [AWXAPIClientConfiguration sharedConfiguration].baseURL;
    NSURL *requestURL = [NSURL URLWithString:@"api/v1/checkout" relativeToURL:paymentBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:NSUUID.UUID.UUIDString forHTTPHeaderField:@"Awx-Tracker"];
    [request setValue:@"Airwallex-iOS-SDK" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
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
