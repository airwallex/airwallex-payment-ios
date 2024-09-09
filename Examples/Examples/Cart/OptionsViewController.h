//
//  OptionsViewController.h
//  Examples
//
//  Created by Victor Zhu on 2020/3/20.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomerFetchable;

@interface OptionsViewController : UIViewController

@property (strong, nonatomic) id<CustomerFetchable> customerFetcher;

@end
