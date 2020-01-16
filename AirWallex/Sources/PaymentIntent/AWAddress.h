//
//  AWAddress.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWAddress : NSObject <AWJSONifiable>

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy, nullable) NSString *state;
@property (nonatomic, copy, nullable) NSString *postcode;

@end

NS_ASSUME_NONNULL_END
