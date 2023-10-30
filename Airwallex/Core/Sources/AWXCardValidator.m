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
                        type:(AWXBrandType)type {
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
                         type:(AWXBrandType)type {
    return [[AWXBrand alloc] initWithName:name rangeStart:rangeStart rangeEnd:rangeEnd length:length type:type];
}

- (BOOL)matchesPrefix:(NSString *)number {
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

@property (nonatomic, copy, readonly) AWXBrand *defaultBrand;

@end

@implementation AWXCardValidator

@synthesize defaultBrand;

+ (instancetype)sharedCardValidator {
    static AWXCardValidator *sharedCardValidator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCardValidator = [self new];
    });
    return sharedCardValidator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        defaultBrand = [AWXBrand brandWithName:@""
                                    rangeStart:@""
                                      rangeEnd:@""
                                        length:16
                                          type:AWXBrandTypeUnknown];
    }
    return self;
}

- (NSArray<AWXBrand *> *)brands {
    return @[
        // Unknown
        defaultBrand,

        // American Express
        [AWXBrand brandWithName:@"Amex"
                     rangeStart:@"34"
                       rangeEnd:@"34"
                         length:15
                           type:AWXBrandTypeAmex],
        [AWXBrand brandWithName:@"Amex"
                     rangeStart:@"37"
                       rangeEnd:@"37"
                         length:15
                           type:AWXBrandTypeAmex],
        [AWXBrand brandWithName:@"American Express"
                     rangeStart:@"34"
                       rangeEnd:@"34"
                         length:15
                           type:AWXBrandTypeAmex],
        [AWXBrand brandWithName:@"American Express"
                     rangeStart:@"37"
                       rangeEnd:@"37"
                         length:15
                           type:AWXBrandTypeAmex],

        // Diners Club
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"300"
                       rangeEnd:@"305"
                         length:14
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"300"
                       rangeEnd:@"305"
                         length:16
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diner"
                     rangeStart:@"300"
                       rangeEnd:@"305"
                         length:19
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"36"
                       rangeEnd:@"36"
                         length:14
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"36"
                       rangeEnd:@"36"
                         length:16
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"36"
                       rangeEnd:@"36"
                         length:19
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"38"
                       rangeEnd:@"39"
                         length:14
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"38"
                       rangeEnd:@"39"
                         length:16
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners"
                     rangeStart:@"38"
                       rangeEnd:@"39"
                         length:19
                           type:AWXBrandTypeDinersClub],
        [AWXBrand brandWithName:@"Diners Club International"
                     rangeStart:@"300"
                       rangeEnd:@"305"
                         length:14
                           type:AWXBrandTypeDinersClub],

        // Discover
        [AWXBrand brandWithName:@"Discover"
                     rangeStart:@"6011"
                       rangeEnd:@"6011"
                         length:16
                           type:AWXBrandTypeDiscover],
        [AWXBrand brandWithName:@"Discover"
                     rangeStart:@"644"
                       rangeEnd:@"65"
                         length:16
                           type:AWXBrandTypeDiscover],
        [AWXBrand brandWithName:@"Discover"
                     rangeStart:@"6011"
                       rangeEnd:@"6011"
                         length:19
                           type:AWXBrandTypeDiscover],
        [AWXBrand brandWithName:@"Discover"
                     rangeStart:@"644"
                       rangeEnd:@"65"
                         length:19
                           type:AWXBrandTypeDiscover],

        // JCB
        [AWXBrand brandWithName:@"JCB"
                     rangeStart:@"3528"
                       rangeEnd:@"3589"
                         length:16
                           type:AWXBrandTypeJCB],

        // Mastercard
        [AWXBrand brandWithName:@"Mastercard"
                     rangeStart:@"50"
                       rangeEnd:@"59"
                         length:16
                           type:AWXBrandTypeMastercard],
        [AWXBrand brandWithName:@"Mastercard"
                     rangeStart:@"22"
                       rangeEnd:@"27"
                         length:16
                           type:AWXBrandTypeMastercard],
        [AWXBrand brandWithName:@"Mastercard"
                     rangeStart:@"67"
                       rangeEnd:@"67"
                         length:16
                           type:AWXBrandTypeMastercard],

        // UnionPay
        [AWXBrand brandWithName:@"UnionPay"
                     rangeStart:@"62"
                       rangeEnd:@"62"
                         length:16
                           type:AWXBrandTypeUnionPay],
        [AWXBrand brandWithName:@"UnionPay"
                     rangeStart:@"62"
                       rangeEnd:@"62"
                         length:17
                           type:AWXBrandTypeUnionPay],
        [AWXBrand brandWithName:@"UnionPay"
                     rangeStart:@"62"
                       rangeEnd:@"62"
                         length:18
                           type:AWXBrandTypeUnionPay],
        [AWXBrand brandWithName:@"UnionPay"
                     rangeStart:@"62"
                       rangeEnd:@"62"
                         length:19
                           type:AWXBrandTypeUnionPay],
        [AWXBrand brandWithName:@"Union Pay"
                     rangeStart:@"62"
                       rangeEnd:@"62"
                         length:16
                           type:AWXBrandTypeUnionPay],

        // Visa
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"40"
                       rangeEnd:@"49"
                         length:16
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"413600"
                       rangeEnd:@"413600"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"444509"
                       rangeEnd:@"444509"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"444550"
                       rangeEnd:@"444550"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"450603"
                       rangeEnd:@"450603"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"450617"
                       rangeEnd:@"450617"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"450628"
                       rangeEnd:@"450628"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"450636"
                       rangeEnd:@"450636"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"450640"
                       rangeEnd:@"450640"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"450662"
                       rangeEnd:@"450662"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"463100"
                       rangeEnd:@"463100"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"476142"
                       rangeEnd:@"476142"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"476143"
                       rangeEnd:@"476143"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"492901"
                       rangeEnd:@"492901"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"492920"
                       rangeEnd:@"492920"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"492923"
                       rangeEnd:@"492923"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"492928"
                       rangeEnd:@"492928"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"492937"
                       rangeEnd:@"492937"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"492939"
                       rangeEnd:@"492939"
                         length:13
                           type:AWXBrandTypeVisa],
        [AWXBrand brandWithName:@"Visa"
                     rangeStart:@"492960"
                       rangeEnd:@"492960"
                         length:13
                           type:AWXBrandTypeVisa]
    ];
}

- (NSInteger)maxLengthForCardNumber:(NSString *)cardNumber {
    NSArray *brands = [self brandsForCardNumber:cardNumber];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:false];
    AWXBrand *brandWithMaxLength = [brands sortedArrayUsingDescriptors:@[sortDescriptor]].firstObject;
    if (brandWithMaxLength) {
        return brandWithMaxLength.length;
    }
    return defaultBrand.length;
}

- (nullable AWXBrand *)brandForCardNumber:(NSString *)cardNumber {
    NSArray *brandsfilteredByPrefix = [self brandsForCardNumber:cardNumber];

    AWXBrand *brandWithSameLength = [brandsfilteredByPrefix filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
                                                                AWXBrand *brand = (AWXBrand *)evaluatedObject;
                                                                return brand.length == cardNumber.length;
                                                            }]]
                                        .firstObject;
    if (brandWithSameLength) {
        return brandWithSameLength;
    }
    return brandsfilteredByPrefix.firstObject;
}

- (AWXBrand *)brandForCardName:(NSString *)name {
    NSArray *filtered = [self.brands filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
                                         AWXBrand *brand = (AWXBrand *)evaluatedObject;
                                         return [brand.name compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame;
                                     }]];
    return filtered.firstObject;
}

- (BOOL)isValidCardLength:(NSString *)cardNumber {
    AWXBrand *brand = [self brandForCardNumber:cardNumber];
    if (brand) {
        return brand.length == cardNumber.length;
    }
    return NO;
}

+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(AWXBrandType)type {
    switch (type) {
    case AWXBrandTypeAmex:
        return @[@4, @6, @5];
    case AWXBrandTypeDinersClub:
        return @[@4, @6, @9];
    default:
        return @[@4, @4, @4];
    }
}

#pragma mark - Private methods

- (NSArray<AWXBrand *> *)brandsForCardNumber:(NSString *)cardNumber {
    return [self.brands filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
                            AWXBrand *brand = (AWXBrand *)evaluatedObject;
                            return brand.type != AWXBrandTypeUnknown && [brand matchesPrefix:cardNumber];
                        }]];
}

@end
