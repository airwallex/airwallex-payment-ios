//
//  AirwallexExamplesKeys.h
//  Examples
//
//  Created by Victor Zhu on 2021/7/1.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AirwallexExamplesKeys : NSObject

@property (nonatomic, readonly) NSString *apiKey;
@property (nonatomic, readonly) NSString *clientId;
@property (nonatomic, readonly) NSString *baseUrl;
@property (nonatomic, readonly) NSString *weChatAppId;
@property (nonatomic, readonly) NSString *amount;
@property (nonatomic, readonly) NSString *currency;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
