//
//  AWXFormMapping.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/29.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXFormMapping.h"
#import "AWXForm.h"
#import "AWXUtils.h"

@implementation AWXFormMapping

//- (NSString *)title
//{
//    return NSLocalizedString(@"POLi", @"POLi");
//}

//- (NSString *)title
//{
//    return NSLocalizedString(@"Bank transfer", @"Bank transfer");
//}

- (NSString *)title
{
    return NSLocalizedString(@"Select your bank", @"Select your bank");
}

//- (NSArray *)forms
//{
//    return @[
//        [AWXForm formWithTitle:@"Name" type:AWXFormTypeField],
//        [AWXForm formWithTitle:@"Pay now" type:AWXFormTypeButton],
//    ];
//}

//- (NSArray *)forms
//{
//    return @[
//        [AWXForm formWithTitle:@"Name" type:AWXFormTypeField],
//        [AWXForm formWithTitle:@"Email" type:AWXFormTypeField],
//        [AWXForm formWithTitle:@"Phone" type:AWXFormTypeField],
//    ];
//}

- (NSArray *)forms
{
    return @[
        [AWXForm formWithTitle:@"Affin Bank" type:AWXFormTypeOption logo:@"affin_bank"],
        [AWXForm formWithTitle:@"Alliance Bank" type:AWXFormTypeOption logo:@"alliance_bank"],
        [AWXForm formWithTitle:@"AmBank" type:AWXFormTypeOption logo:@"ambank"],
        [AWXForm formWithTitle:@"Bank Islam" type:AWXFormTypeOption logo:@"bank_islam"],
        [AWXForm formWithTitle:@"Bank Kerjasama Rakyat Malaysia" type:AWXFormTypeOption logo:@"bank_kerjasama_rakyat"],
        [AWXForm formWithTitle:@"Bank Muamalat" type:AWXFormTypeOption logo:@"bank_muamalat"],
        [AWXForm formWithTitle:@"Bank Simpanan Nasional" type:AWXFormTypeOption logo:@"bank_simpanan_nasional"]
    ];
}

@end
