//
//  AWAPIClient.h
//  Examples
//
//  Created by Victor Zhu on 2020/1/14.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWPaymentConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface AWAPIClient : NSObject

@property (nonatomic, copy) AWPaymentConfiguration *configuration;

@end

NS_ASSUME_NONNULL_END
