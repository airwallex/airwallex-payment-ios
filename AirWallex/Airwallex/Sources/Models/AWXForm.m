//
//  AWXForm.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXForm.h"

@implementation AWXForm

+ (instancetype)formWithTitle:(NSString *)title type:(AWXFormType)type
{
    return [self formWithTitle:title type:type logo:nil];
}

+ (instancetype)formWithTitle:(NSString *)title type:(AWXFormType)type logo:(nullable NSString *)logo
{
    AWXForm *form = [AWXForm new];
    form.title = title;
    form.type = type;
    form.logo = logo;
    return form;
}

@end
