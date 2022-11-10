//
//  AWXFloatingCardTextField.h
//  Core
//
//  Created by Hector.Huang on 2022/11/10.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXWidgets.h"

/**
 A customized view for card number
 */
@interface AWXFloatingCardTextField : AWXFloatingLabelTextField

@property (nonatomic, copy) NSArray *cardBrands;
@property (nonatomic, strong) NSString *floatingText;
@property (nonatomic, copy) NSString * (^validationMessageCallback)(NSString *);

@end
