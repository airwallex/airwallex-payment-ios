//
//  AWConfirmPaymentintentResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWConfirmPaymentintentResponse.h"

@interface AWConfirmPaymentintentResponse ()

@property (nonatomic, copy, readwrite) NSString *clientSecret;

@end

@implementation AWConfirmPaymentintentResponse

+ (id <AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWConfirmPaymentintentResponse *response = [[AWConfirmPaymentintentResponse alloc] init];
    response.clientSecret = [responseObject valueForKey:@"client_secret"];
    return response;
}

@end
