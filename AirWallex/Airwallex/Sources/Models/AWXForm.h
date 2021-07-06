//
//  AWXForm.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXForm : NSObject

@property (nonatomic) AWXFormType type;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *defaultValue;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, nullable) NSString *logo;

+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title;
+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title placeholder:(nullable NSString *)placeholder logo:(nullable NSString *)logo;

@end

NS_ASSUME_NONNULL_END
