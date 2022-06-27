//
//  WebViewController.h
//  Examples
//
//  Created by Victor Zhu on 2021/5/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy, nonnull) NSString *url;
@property (nonatomic, copy, nonnull) NSString *referer;

@end
