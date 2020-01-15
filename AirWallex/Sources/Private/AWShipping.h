//
//  AWShipping.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWShipping : NSObject

@property (nonatomic, strong) NSString *shippingMethod;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) AWAddress *address;

@end

NS_ASSUME_NONNULL_END
