//
//  AWSecurityService.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/4/21.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWSecurityService.h"
#import "AWConstants.h"
#import <TrustDefender/TrustDefender.h>

@interface AWSecurityService ()

@property (nonatomic, strong) THMTrustDefender *defender;

@end

@implementation AWSecurityService

+ (instancetype)sharedService
{
    static AWSecurityService *sharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [self new];
    });
    return sharedService;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defender = [THMTrustDefender sharedInstance];
        [self.defender configure:@{
            THMOrgID: AWCyberSourceOrganizationID
        }];
    }
    return self;
}

- (void)doProfile:(NSString *)intentId
       completion:(void(^)(NSString * _Nullable))completion
{
    NSString *fraudSessionId = [NSString stringWithFormat:@"%@%f", intentId, [[NSDate date] timeIntervalSince1970]];
    NSString *sessionId = [NSString stringWithFormat:@"%@%@", AWCyberSourceMerchantID, fraudSessionId];
    [self.defender doProfileRequestWithOptions:@{@"session_id": sessionId}
                              andCallbackBlock:^(NSDictionary *result) {
        NSString *sessionId = [result valueForKey:THMSessionID];
        completion(sessionId ?: @"");
    }];
}

@end
