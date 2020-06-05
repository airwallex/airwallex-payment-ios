//
//  AWXCardValidator.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCardValidator.h"

@implementation AWXBrand

- (instancetype)initWithName:(NSString *)name
                  rangeStart:(NSString *)rangeStart
                    rangeEnd:(NSString *)rangeEnd
                      length:(NSInteger)length
                       type:(AWXBrandType)type
{
    if (self = [super init]) {
        self.name = name;
        self.rangeStart = rangeStart;
        self.rangeEnd = rangeEnd;
        self.length = length;
        self.type = type;
    }
    return self;
}

+ (instancetype)brandWithName:(NSString *)name
                   rangeStart:(NSString *)rangeStart
                     rangeEnd:(NSString *)rangeEnd
                       length:(NSInteger)length
                        type:(AWXBrandType)type
{
    return [[AWXBrand alloc] initWithName:name rangeStart:rangeStart rangeEnd:rangeEnd length:length type:type];
}

- (BOOL)matchesNumber:(NSString *)number
{
    BOOL withinLowRange = NO;
    BOOL withinHighRange = NO;

    if (number.length < self.rangeStart.length) {
        withinLowRange = number.integerValue >= [self.rangeStart substringToIndex:number.length].integerValue;
    } else {
        withinLowRange = [number substringToIndex:self.rangeStart.length].integerValue >= self.rangeStart.integerValue;
    }

    if (number.length < self.rangeEnd.length) {
        withinHighRange = number.integerValue <= [self.rangeEnd substringToIndex:number.length].integerValue;
    } else {
        withinHighRange = [number substringToIndex:self.rangeEnd.length].integerValue <= self.rangeEnd.integerValue;
    }

    return withinLowRange && withinHighRange;
}

@end

@interface AWXCardValidator ()

@end

@implementation AWXCardValidator

+ (instancetype)sharedCardValidator
{
    static AWXCardValidator *sharedCardValidator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCardValidator = [self new];
    });
    return sharedCardValidator;
}

- (NSArray <AWXBrand *> *)brands
{
    return @[
        // Unknown
        [AWXBrand brandWithName:@"" rangeStart:@"" rangeEnd:@"" length:16 type:AWXBrandTypeUnknown],

        // American Express
        [AWXBrand brandWithName:@"American Express" rangeStart:@"34" rangeEnd:@"34" length:15 type:AWXBrandTypeAmex],
        [AWXBrand brandWithName:@"American Express" rangeStart:@"37" rangeEnd:@"37" length:15 type:AWXBrandTypeAmex],

        // Diners Club
        [AWXBrand brandWithName:@"Diners Club" rangeStart:@"30" rangeEnd:@"30" length:14 type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners Club" rangeStart:@"36" rangeEnd:@"36" length:14 type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners Club" rangeStart:@"38" rangeEnd:@"39" length:14 type:AWXBrandTypeDinersClub],

        // Discover
        [AWXBrand brandWithName:@"Discover" rangeStart:@"60" rangeEnd:@"60" length:16 type:AWXBrandTypeDiscover],
        [AWXBrand brandWithName:@"Discover" rangeStart:@"64" rangeEnd:@"65" length:16 type:AWXBrandTypeDiscover],

        // JCB
        [AWXBrand brandWithName:@"JCB" rangeStart:@"35" rangeEnd:@"35" length:16 type:AWXBrandTypeJCB],

        // Mastercard
        [AWXBrand brandWithName:@"Mastercard" rangeStart:@"50" rangeEnd:@"59" length:16 type:AWXBrandTypeMastercard],
        [AWXBrand brandWithName:@"Mastercard" rangeStart:@"22" rangeEnd:@"27" length:16 type:AWXBrandTypeMastercard],
        [AWXBrand brandWithName:@"Mastercard" rangeStart:@"67" rangeEnd:@"67" length:16 type:AWXBrandTypeMastercard],

        // UnionPay
        [AWXBrand brandWithName:@"UnionPay" rangeStart:@"62" rangeEnd:@"62" length:16 type:AWXBrandTypeUnionPay],

        // Visa
        [AWXBrand brandWithName:@"Visa" rangeStart:@"40" rangeEnd:@"49" length:16 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"413600" rangeEnd:@"413600" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"444509" rangeEnd:@"444509" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"444550" rangeEnd:@"444550" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"450603" rangeEnd:@"450603" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"450617" rangeEnd:@"450617" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"450628" rangeEnd:@"450628" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"450636" rangeEnd:@"450636" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"450640" rangeEnd:@"450640" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"450662" rangeEnd:@"450662" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"463100" rangeEnd:@"463100" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"476142" rangeEnd:@"476142" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"476143" rangeEnd:@"476143" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"492901" rangeEnd:@"492901" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"492920" rangeEnd:@"492920" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"492923" rangeEnd:@"492923" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"492928" rangeEnd:@"492928" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"492937" rangeEnd:@"492937" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"492939" rangeEnd:@"492939" length:13 type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa" rangeStart:@"492960" rangeEnd:@"492960" length:13 type:AWXBrandTypeVisa]
    ];
}

- (nullable AWXBrand *)brandForCardNumber:(NSString *)cardNumber
{
    NSArray *filtered = [self.brands filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        AWXBrand *brand = (AWXBrand *)evaluatedObject;
        return brand.type != AWXBrandTypeUnknown && [brand matchesNumber:cardNumber];
    }]];
    return filtered.firstObject;
}

+ (NSArray <NSNumber *> *)cardNumberFormatForBrand:(AWXBrandType)type
{
    switch (type) {
        case AWXBrandTypeAmex:
            return @[@4, @6, @5];
        case AWXBrandTypeDinersClub:
            return @[@4, @6, @4];
        default:
            return @[@4, @4, @4, @4];
    }
}

@end
