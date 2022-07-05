//
//  AWXPaymentFormViewModel.h
//  Redirect
//
//  Created by Hector.Huang on 2022/7/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXPaymentFormViewModel : NSObject

@property (nonatomic, strong, nonnull) AWXSession *session;

- (instancetype)initWithSession:(AWXSession *)session;

- (NSString *)phonePrefix;

@end

NS_ASSUME_NONNULL_END
