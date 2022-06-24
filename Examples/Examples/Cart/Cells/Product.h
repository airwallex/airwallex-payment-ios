//
//  Product.h
//  Examples
//
//  Created by Jarrod Robins on 20/6/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic, strong, nonnull) NSString *name, *detail;
@property (nonatomic, strong, nonnull) NSDecimalNumber *price;

- (instancetype _Nonnull)initWithName:(nonnull NSString *)name
                               detail:(nonnull NSString *)detail
                                price:(nonnull NSDecimalNumber *)price;

@end
