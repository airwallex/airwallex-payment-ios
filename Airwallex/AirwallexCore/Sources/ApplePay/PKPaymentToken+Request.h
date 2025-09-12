//
//  PKPaymentToken+Request.h
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <PassKit/PassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKPaymentToken (Request)

- (nullable NSDictionary *)payloadForRequestWithBilling:(nullable NSDictionary *)billingPayload
                                                orError:(NSError *_Nullable *)error;

@end

NS_ASSUME_NONNULL_END
