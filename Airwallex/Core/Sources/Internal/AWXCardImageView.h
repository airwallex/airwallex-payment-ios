//
//  AWXCardImageView.h
//  Core
//
//  Created by Hector.Huang on 2022/11/8.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXCardImageView : UIImageView

@property (nonatomic, assign) AWXBrandType cardBrand;

- (instancetype)initWithCardBrand:(AWXBrandType)brand;

@end
