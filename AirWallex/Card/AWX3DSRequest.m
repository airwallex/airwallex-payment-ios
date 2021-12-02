//
//  AWX3DSRequest.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSRequest.h"
#import "AWX3DSResponse.h"

@implementation AWX3DSCollectDeviceDataRequest

- (NSString *)path
{
    return @"";
}

- (AWXHTTPMethod)method
{
    return AWXHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    return @{@"JWT": self.jwt, @"Bin": self.bin};
}

- (Class)responseClass
{
    return AWX3DSCollectDeviceDataResponse.class;
}
@end
