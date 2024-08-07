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

- (instancetype)initWithCardBrand:(AWXCardBrand)brand {
    self = [super initWithImage:[UIImage imageNamed:brand inBundle:[NSBundle resourceBundle]]];
    if (self) {
        self.cardBrand = brand;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

@end
