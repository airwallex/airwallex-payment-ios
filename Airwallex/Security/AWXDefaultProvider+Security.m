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

@implementation AWXDefaultProvider (Security)

- (void)setDevice:(void (^)(AWXDevice *_Nonnull))completion {
    [[AWXSecurityService sharedService] doProfile:self.session.paymentIntentId
                                       completion:^(NSString *_Nullable sessionId) {
                                           AWXDevice *device = [AWXDevice new];
                                           device.deviceId = sessionId;
                                           completion(device);
                                       }];
}

@end