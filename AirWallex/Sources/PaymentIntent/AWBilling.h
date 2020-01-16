//
//  AWBilling.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"
#import "AWAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWBilling : NSObject <AWJSONifiable>

@property (nonatomic, strong) AWAddress *address;
@property (nonatomic, copy) NSString *dateOfBirth;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phoneNumber;

@end

NS_ASSUME_NONNULL_END
