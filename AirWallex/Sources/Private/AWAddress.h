//
//  AWAddress.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWAddress : NSObject

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *postcode;

@end

NS_ASSUME_NONNULL_END
