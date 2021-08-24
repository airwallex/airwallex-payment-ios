//
//  AWXDefaultActionProvider.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXDefaultActionProvider : AWXDefaultProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction;

@end

NS_ASSUME_NONNULL_END
