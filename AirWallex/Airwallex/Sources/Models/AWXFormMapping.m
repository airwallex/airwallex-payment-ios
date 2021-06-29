//
//  AWXFormMapping.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXFormMapping.h"
#import "AWXForm.h"

@implementation AWXFormMapping

//- (NSString *)title
//{
//    return NSLocalizedString(@"POLi", @"POLi");
//}

- (NSString *)title
{
    return NSLocalizedString(@"Bank transfer", @"Bank transfer");
}

//- (NSArray *)forms
//{
//    return @[
//        [AWXForm formWithTitle:@"Name" type:AWXFormTypeField],
//        [AWXForm formWithTitle:@"Pay now" type:AWXFormTypeButton],
//    ];
//}

- (NSArray *)forms
{
    return @[
        [AWXForm formWithTitle:@"Name" type:AWXFormTypeField],
        [AWXForm formWithTitle:@"Email" type:AWXFormTypeField],
        [AWXForm formWithTitle:@"Phone" type:AWXFormTypeField],
    ];
}

@end
