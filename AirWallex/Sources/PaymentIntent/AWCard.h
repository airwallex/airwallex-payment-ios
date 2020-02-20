//
//  AWCard.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"
#import "AWParseable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWCard : NSObject <AWJSONifiable, AWParseable>

@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *expiryMonth;
@property (nonatomic, copy) NSString *expiryYear;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *cvc;
@property (nonatomic, copy, nullable) NSString *bin;
@property (nonatomic, copy, nullable) NSString *last4;
@property (nonatomic, copy, nullable) NSString *brand;
@property (nonatomic, copy, nullable) NSString *country;
@property (nonatomic, copy, nullable) NSString *funding;
@property (nonatomic, copy, nullable) NSString *fingerprint;

@end

NS_ASSUME_NONNULL_END
