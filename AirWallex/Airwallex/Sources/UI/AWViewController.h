//
//  AWViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWViewController : UIViewController

- (IBAction)close:(id)sender;
- (IBAction)pop:(id)sender;
- (IBAction)unwindToViewController:(UIStoryboardSegue *)unwindSegue;

@end

NS_ASSUME_NONNULL_END
