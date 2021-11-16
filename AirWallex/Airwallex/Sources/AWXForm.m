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
    return [self formWithKey:key type:type title:title textFieldType:AWXTextFieldTypeFirstName];
}

+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title textFieldType:(AWXTextFieldType)textFieldType
{
    return [self formWithKey:key type:type title:title textFieldType:textFieldType logo:nil];
}

+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title logo:(NSURL *)logo
{
    return [self formWithKey:key type:type title:title textFieldType:AWXTextFieldTypeFirstName logo:logo];
}

+ (instancetype)formWithKey:(NSString *)key type:(AWXFormType)type title:(NSString *)title textFieldType:(AWXTextFieldType)textFieldType logo:(nullable NSURL *)logo
{
    AWXForm *form = [AWXForm new];
    form.key = key;
    form.type = type;
    form.textFieldType = textFieldType;
    form.title = title;
    form.logo = logo;
    return form;
}

@end
