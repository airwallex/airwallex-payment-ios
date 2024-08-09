//
//  FlowWithUIViewController.h
//  Examples
//
//  Created by Tony He (CTR) on 2024/8/8.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWXPlaceDetails;

NS_ASSUME_NONNULL_BEGIN

@interface FlowWithUIViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) AWXPlaceDetails *shipping;

@end

NS_ASSUME_NONNULL_END
