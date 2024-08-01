//
//  NSObject+Logging.h
//  Core
//
//  Created by Tony He (CTR) on 2024/7/9.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Logging)

- (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

@end

NS_ASSUME_NONNULL_END
