//
//  AWProduct.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWProduct : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *quantity;
@property (nonatomic, strong) NSString *sku;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *unitPrice;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *desc;

@end

NS_ASSUME_NONNULL_END
