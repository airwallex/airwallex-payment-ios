//
//  AWXSession+Internal.h
//  Core
//
//  Created by Jin Wang on 5/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXSession.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXSession (Internal)

- (NSArray<AWXPaymentMethodType *> *)filteredPaymentMethodTypes:(NSArray<AWXPaymentMethodType *> *)items;

@end

NS_ASSUME_NONNULL_END
