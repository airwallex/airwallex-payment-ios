//
//  AWXDefaultProvider+Security.m
//  Airwallex
//
//  Created by Hector.Huang on 2023/1/29.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider+Security.h"
#import "AWXSecurityService.h"
#import "AWXSession.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXDefaultProvider (Security)

- (void)setDeviceWithSessionId:(NSString *)sessionId
                    completion:(void (^)(AWXDevice *_Nonnull))completion {
    [[AWXSecurityService sharedService] doProfile:sessionId
                                       completion:^(NSString *_Nullable sessionId) {
                                           AWXDevice *device = [[AWXDevice alloc] initWithDeviceId:sessionId];
                                           completion(device);
                                       }];
}

@end
