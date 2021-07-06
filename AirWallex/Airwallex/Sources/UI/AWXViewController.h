//
//  AWXViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWXViewController : UIViewController

@property (nonatomic) BOOL isFlow;

- (void)unregisterKeyboard;
- (void)registerKeyboard;
- (void)enableTapToDismiss;
- (UIView *)activeField;
- (NSLayoutConstraint *)bottomLayoutConstraint;
- (void)setActiveField:(UIView *)field;
- (UIScrollView *)activeScrollView;
- (IBAction)close:(id)sender;
- (IBAction)pop:(id)sender;
- (IBAction)unwindToViewController:(UIStoryboardSegue *)unwindSegue;

@end

NS_ASSUME_NONNULL_END
