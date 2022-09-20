//
//  AWXCardViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCardViewModel.h"
#import "AWXViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXCardViewController` provides a form to create card
 */
@interface AWXCardViewController : AWXViewController

@property (nonatomic, strong) AWXCardViewModel *viewModel;

/**
 A boolean which can switch to billing form
 */
@property (nonatomic) BOOL sameAsShipping;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
