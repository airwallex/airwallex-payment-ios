//
//  AWXForm.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXForm.h"

@implementation AWXForm

+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title
{
    return [self formWithKey:key type:type title:title placeholder:nil logo:nil];
}

+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title placeholder:(nullable NSString *)placeholder logo:(nullable NSURL *)logo
{
    AWXForm *form = [AWXForm new];
    form.key = key;
    form.type = type;
    form.placeholder = placeholder;
    form.title = title;
    form.logo = logo;
    return form;
}

@end
