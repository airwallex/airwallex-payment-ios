//
//  AWXRedirectThreeDSResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXRedirectThreeDSResponse.h"

@interface AWXRedirectThreeDSResponse ()

@property (nonatomic, copy, readwrite) NSString *jwt;
@property (nonatomic, copy, readwrite) NSString *stage;
@property (nonatomic, copy, readwrite, nullable) NSString *acs;
@property (nonatomic, copy, readwrite, nullable) NSString *xid;
@property (nonatomic, copy, readwrite, nullable) NSString *req;

@end

@implementation AWXRedirectThreeDSResponse

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXRedirectThreeDSResponse *response = [[AWXRedirectThreeDSResponse alloc] init];
    response.jwt = json[@"jwt"];
    response.stage = json[@"stage"];
    response.acs = json[@"acs"];
    response.xid = json[@"xid"];
    response.req = json[@"req"];
    return response;
}

@end
