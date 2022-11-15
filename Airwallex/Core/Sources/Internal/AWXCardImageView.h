//
//  AWXCardImageView.h
//  Core
//
//  Created by Hector.Huang on 2022/11/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardValidator.h"
#import <UIKit/UIKit.h>

@interface AWXCardImageView : UIImageView

@property (nonatomic, assign) AWXBrandType cardBrand;

- (instancetype)initWithCardBrand:(AWXBrandType)brand;

@end
