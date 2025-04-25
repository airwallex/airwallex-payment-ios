//
//  AWXFloatingCvcTextField.h
//  Core
//
//  Created by Hector.Huang on 2024/9/2.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXWidgets.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXFloatingCvcTextField : AWXFloatingLabelTextField

@property (nonatomic) NSInteger maxLength;

@property (nonatomic, copy, nullable) NSString * (^validationMessageCallback)(NSString *);

@property (nonatomic, copy, nullable) void (^textDidChangeCallback)(NSString *);

@end

NS_ASSUME_NONNULL_END
