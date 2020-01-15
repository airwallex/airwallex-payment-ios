//
//  AWOrder.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWShipping.h"
#import "AWProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWOrder : NSObject

@property (nonatomic, strong) AWShipping *shipping;
@property (nonatomic, strong) NSArray <AWProduct *>*products;

@end

NS_ASSUME_NONNULL_END
