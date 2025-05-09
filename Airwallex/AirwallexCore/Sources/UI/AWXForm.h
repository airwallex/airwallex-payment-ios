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

@property (nonatomic, assign) AWXFormType type;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) AWXTextFieldType textFieldType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, nullable) NSURL *logo;

+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title;
+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title textFieldType:(AWXTextFieldType)textFieldType;
+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title logo:(NSURL *_Nullable)logo;

@end

NS_ASSUME_NONNULL_END
