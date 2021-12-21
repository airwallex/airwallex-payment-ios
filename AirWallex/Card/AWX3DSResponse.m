//
//  AWX3DSResponse.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSResponse.h"

@implementation AWX3DSCollectDeviceDataResponse

+ (AWXResponse *)parse:(NSData *)data
{
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", html);
    
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWX3DSCollectDeviceDataResponse *response = [[AWX3DSCollectDeviceDataResponse alloc] init];
    return response;
}

@end
