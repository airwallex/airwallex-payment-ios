//
//  AWXDefaultProvider+Security.h
//  Airwallex
//
//  Created by Hector.Huang on 2023/1/29.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"

@class AWXDevice;

NS_ASSUME_NONNULL_BEGIN

@interface AWXDefaultProvider (Security)

- (void)setDeviceWithSessionId:(NSString *)sessionId
                    completion:(void (^)(AWXDevice *_Nonnull))completion;

@end

NS_ASSUME_NONNULL_END
