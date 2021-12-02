//
//  AWX3DSService.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSService.h"
#import "AWXAPIClient.h"
#import "AWX3DSRequest.h"

@interface AWX3DSService ()

@property (strong, nonatomic) AWXAPIClient *client;
@property (strong, nonatomic) NSString *transactionId;

@end

@implementation AWX3DSService

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)presentThreeDSFlowWithServerJwt:(NSString *)serverJwt url:(NSURL *)url
{
    AWXAPIClientConfiguration *configuration = [AWXAPIClientConfiguration new];
    configuration.baseURL = url;
    self.client = [[AWXAPIClient alloc] initWithConfiguration:configuration];
    
    AWX3DSCollectDeviceDataRequest *request = [AWX3DSCollectDeviceDataRequest new];
    request.jwt = serverJwt;
    [self.client send:request handler:^(AWXResponse * _Nullable response, NSError * _Nullable error) {
    
    }];
}

- (void)confirmWithReferenceId:(NSString *)referenceId
{
    
}

@end
