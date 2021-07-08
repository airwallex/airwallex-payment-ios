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

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *weChatAppId;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *currency;

+ (instancetype)shared;
- (void)resetKeys;

@end

NS_ASSUME_NONNULL_END
