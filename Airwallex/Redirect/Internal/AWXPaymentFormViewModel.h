//
//  AWXPaymentFormViewModel.h
//  Redirect
//
//  Created by Hector.Huang on 2022/7/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXSession.h"

@interface AWXPaymentFormViewModel : NSObject

@property (nonatomic, strong, nonnull) AWXSession *session;

- (instancetype)initWithSession:(AWXSession *)session;

- (NSString *)phonePrefix;

@end
