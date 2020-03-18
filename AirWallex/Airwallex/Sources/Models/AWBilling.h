//
//  AWBilling.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"
#import "AWParseable.h"
#import "AWAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWBilling : NSObject <AWJSONifiable, AWParseable, NSCopying>

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, copy, nullable) NSString *dateOfBirth;
@property (nonatomic, copy, nullable) NSString *phoneNumber;
@property (nonatomic, copy) AWAddress *address;

@end

@interface AWBilling (Utils)

- (nullable NSString *)validate;

@end

NS_ASSUME_NONNULL_END
