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

@interface AWXBrand : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *rangeStart;
@property (nonatomic, strong) NSString *rangeEnd;
@property (nonatomic) NSInteger length;
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

@interface AWXCardValidator : NSObject

+ (instancetype)sharedCardValidator;
- (nullable AWXBrand *)brandForCardNumber:(NSString *)cardNumber;
+ (NSArray <NSNumber *> *)cardNumberFormatForBrand:(AWXBrandType)type;

@end

NS_ASSUME_NONNULL_END
