//
//  AWCardValidator.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AWBrandTypeUnknown,
    AWBrandTypeVisa,
    AWBrandTypeAmex,
    AWBrandTypeMastercard,
    AWBrandTypeDiscover,
    AWBrandTypeJCB,
    AWBrandTypeDinersClub,
    AWBrandTypeUnionPay
} AWBrandType;

@interface AWBrand : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *rangeStart;
@property (nonatomic, strong) NSString *rangeEnd;
@property (nonatomic) NSInteger length;
@property (nonatomic) AWBrandType type;

- (instancetype)initWithName:(NSString *)name
                  rangeStart:(NSString *)rangeStart
                    rangeEnd:(NSString *)rangeEnd
                      length:(NSInteger)length
                       type:(AWBrandType)type;
+ (instancetype)brandWithName:(NSString *)name
                   rangeStart:(NSString *)rangeStart
                     rangeEnd:(NSString *)rangeEnd
                       length:(NSInteger)length
                         type:(AWBrandType)type;
- (BOOL)matchesNumber:(NSString *)number;

@end

@interface AWCardValidator : NSObject

+ (instancetype)sharedCardValidator;
- (nullable AWBrand *)brandForCardNumber:(NSString *)cardNumber;
+ (NSArray<NSNumber *> *)cardNumberFormatForBrand:(AWBrandType)type;

@end

NS_ASSUME_NONNULL_END
