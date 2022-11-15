//
//  AWXCardValidator.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AWXBrandTypeUnknown,
    AWXBrandTypeVisa,
    AWXBrandTypeAmex,
    AWXBrandTypeMastercard,
    AWXBrandTypeDiscover,
    AWXBrandTypeJCB,
    AWXBrandTypeDinersClub,
    AWXBrandTypeUnionPay
} AWXBrandType;

/**
 `AWXBrand` manages the card scheme brand.
 */
@interface AWXBrand : NSObject

/**
 The brand name.
 */
@property (nonatomic, strong) NSString *name;

/**
 The start of  card No.
 */
@property (nonatomic, strong) NSString *rangeStart;

/**
 The end of  card No.
 */
@property (nonatomic, strong) NSString *rangeEnd;

/**
 The length of  card No.
 */
@property (nonatomic) NSInteger length;

/**
 The brand type.
 */
@property (nonatomic) AWXBrandType type;

- (instancetype)initWithName:(NSString *)name
                  rangeStart:(NSString *)rangeStart
                    rangeEnd:(NSString *)rangeEnd
                      length:(NSInteger)length
                        type:(AWXBrandType)type;
+ (instancetype)brandWithName:(NSString *)name
                   rangeStart:(NSString *)rangeStart
                     rangeEnd:(NSString *)rangeEnd
                       length:(NSInteger)length
                         type:(AWXBrandType)type;
- (BOOL)matchesNumber:(NSString *)number;

@end

/**
 `AWXCardValidator` manages the card info.
 */
@interface AWXCardValidator : NSObject

+ (instancetype)sharedCardValidator;
- (nullable AWXBrand *)brandForCardNumber:(NSString *)cardNumber;
- (nullable AWXBrand *)brandForCardName:(NSString *)name;
- (BOOL)isValidCardLength:(NSString *)cardNumber;
+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(AWXBrandType)type;

@end

NS_ASSUME_NONNULL_END
