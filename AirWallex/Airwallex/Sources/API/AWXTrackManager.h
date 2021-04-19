//
//  AWXTrackManager.h
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/4/8.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXRequestProtocol.h"
#import "AWXResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXTrackManager : NSObject

+ (instancetype)sharedTrackManager;

- (void)trackWithParameters:(NSDictionary *)parameters
                   completionHandler:(void (^)(NSDictionary * _Nullable result, NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
