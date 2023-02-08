//
//  AWXCardImageView.m
//  Core
//
//  Created by Hector.Huang on 2022/11/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardImageView.h"
#import "AWXUtils.h"

@implementation AWXCardImageView

- (instancetype)initWithCardBrand:(AWXBrandType)brand {
    NSString *imageName = [self imageNameForCardBrand:brand];
    if (imageName) {
        self = [super initWithImage:[UIImage imageNamed:imageName inBundle:[NSBundle resourceBundle]]];
        if (self) {
            self.cardBrand = brand;
            self.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    return self;
}

- (NSString *)imageNameForCardBrand:(AWXBrandType)brand {
    switch (brand) {
    case AWXBrandTypeVisa:
        return @"visa";
    case AWXBrandTypeAmex:
        return @"amex";
    case AWXBrandTypeMastercard:
        return @"mastercard";
    case AWXBrandTypeUnionPay:
        return @"unionpay";
    default:
        return NULL;
    }
}

@end
