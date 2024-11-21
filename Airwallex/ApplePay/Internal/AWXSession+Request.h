//
//  AWXSession+Request.h
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXSession (Request)

- (nullable PKPaymentRequest *)makePaymentRequestOrError:(NSError *_Nullable *)error;

@end

NS_ASSUME_NONNULL_END
