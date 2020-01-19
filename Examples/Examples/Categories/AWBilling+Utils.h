//
//  AWBilling+Utils.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Airwallex/Airwallex.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWBilling (Utils)

- (BOOL)isValid;
- (nullable NSString *)validate;

@end

NS_ASSUME_NONNULL_END
