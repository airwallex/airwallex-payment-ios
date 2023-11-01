//
//  AWXPaymentFormViewModel.h
//  Redirect
//
//  Created by Hector.Huang on 2022/7/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXFormMapping.h"
#import "AWXPaymentMethod.h"
#import "AWXSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXPaymentFormViewModel : NSObject

@property (nonatomic, strong, nonnull) AWXSession *session;
@property (nonatomic, copy, readonly) NSString *pageName;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *additionalInfo;

- (instancetype)initWithSession:(AWXSession *)session paymentMethod:(AWXPaymentMethod *)paymentMethod formMapping:(AWXFormMapping *)formMapping;

- (nullable NSString *)phonePrefix;

@end

NS_ASSUME_NONNULL_END
