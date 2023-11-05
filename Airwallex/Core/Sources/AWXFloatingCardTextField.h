//
//  AWXFloatingCardTextField.h
//  Core
//
//  Created by Hector.Huang on 2022/11/10.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXCardValidator.h"
#import "AWXWidgets.h"

/**
 A customized view for card number
 */
@interface AWXFloatingCardTextField : AWXFloatingLabelTextField

/**
Supported card schemes, meant to be NSArray<AWXBrandType>, but OC can't support primitive types for NSArray in declaration.
Can make it more explicit when we switch to Swift.
*/
@property (nonatomic, copy) NSArray *cardBrands;

@property (nonatomic, strong) NSString *floatingText;

@property (nonatomic, copy, nullable) NSString * (^validationMessageCallback)(NSString *);

@property (nonatomic, copy) void (^brandUpdateCallback)(AWXBrandType);

@end
