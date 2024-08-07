//
//  AWXCardImageView.h
//  Core
//
//  Created by Hector.Huang on 2022/11/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXConstants.h"
#import <UIKit/UIKit.h>

@interface AWXCardImageView : UIImageView

@property (nonatomic, assign) AWXCardBrand cardBrand;

- (instancetype)initWithCardBrand:(AWXCardBrand)brand;

@end
