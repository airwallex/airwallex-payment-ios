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

/**
 `AWXViewController` is the base view controller.
 */
@interface AWXViewController : UIViewController

/**
 One of one-off / recurring / recurring with intent session.
 */
@property (nonatomic, strong) AWXSession *session;

/**
 Provider to handle session
 */
@property (nonatomic, strong) AWXDefaultProvider *provider;

/**
 Show loading activity.
 */
- (void)startAnimating;

/**
 Stop loading activity.
 */
- (void)stopAnimating;

/**
 Enable user to tap the view to end editting state
 */
- (void)enableTapToEndEditting;

/**
 Unregister keyboard listener
 */
- (void)unregisterKeyboard;

/**
 Register keyboard listener
 */
- (void)registerKeyboard;

/**
 Enable user to tap the view to dismiss view controller.
 */
- (void)enableTapToDismiss;

/**
 Return the active field
 */
- (UIView *)activeField;

/**
 Returns layout constraints that affect the bottom of the view
 */
- (NSLayoutConstraint *)bottomLayoutConstraint;

/**
 Update the active field
 */
- (void)setActiveField:(UIView *)field;

/**
 Return the active scrollView
 */
- (UIScrollView *)activeScrollView;

/**
 Dismiss the current view controller
 */
- (void)close:(id)sender;

/**
 Pop the current view controller
 */
- (void)pop:(id)sender;

@end

NS_ASSUME_NONNULL_END
