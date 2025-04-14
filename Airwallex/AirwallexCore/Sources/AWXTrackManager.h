//
//  AWXTrackManager.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/4/8.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXTrackManager : NSObject

+ (instancetype)sharedTrackManager;

- (void)trackWithParameters:(NSDictionary *)parameters
          completionHandler:(void (^)(NSDictionary *_Nullable result, NSError *_Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
