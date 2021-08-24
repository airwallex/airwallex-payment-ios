//
//  AWXViewController.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AWXSession, AWXDefaultProvider;

NS_ASSUME_NONNULL_BEGIN

@interface AWXViewController : UIViewController

@property (nonatomic, strong) AWXSession *session;
@property (nonatomic, strong) AWXDefaultProvider *provider;

- (void)startAnimating;
- (void)stopAnimating;
- (void)enableTapToEndEditting;
- (void)unregisterKeyboard;
- (void)registerKeyboard;
- (void)enableTapToDismiss;
- (UIView *)activeField;
- (NSLayoutConstraint *)bottomLayoutConstraint;
- (void)setActiveField:(UIView *)field;
- (UIScrollView *)activeScrollView;
- (void)close:(id)sender;
- (void)pop:(id)sender;

@end

NS_ASSUME_NONNULL_END
