//
//  AWCard.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWCard : NSObject <AWJSONifiable>

@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *expMonth;
@property (nonatomic, copy) NSString *expYear;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *cvc;

@end

NS_ASSUME_NONNULL_END
