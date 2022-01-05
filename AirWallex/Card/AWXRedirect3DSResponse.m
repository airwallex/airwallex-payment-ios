//
//  AWXRedirect3DSResponse.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXRedirect3DSResponse.h"

@interface AWXRedirect3DSResponse ()

@property (nonatomic, copy, readwrite) NSString *jwt;
@property (nonatomic, copy, readwrite) NSString *bin;

@end

@implementation AWXRedirect3DSResponse

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXRedirect3DSResponse *response = [[AWXRedirect3DSResponse alloc] init];
    response.jwt = json[@"JWT"];
    response.bin = json[@"threeDSMethodData"];
    return response;
}

@end
