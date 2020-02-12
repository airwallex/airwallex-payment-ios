//
//  AWLuhn.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/12.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AWCardTypeAmex,
    AWCardTypeVisa,
    AWCardTypeMastercard,
    AWCardTypeDiscover,
    AWCardTypeDinersClub,
    AWCardTypeJCB,
    AWCardTypeUnknown,
} AWCardType;

NS_ASSUME_NONNULL_BEGIN

@interface AWLuhn : NSObject

+ (BOOL)validateString:(NSString *)string;
+ (AWCardType)typeFromString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
