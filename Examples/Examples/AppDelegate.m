//
//  AppDelegate.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <WechatOpenSDK/WXApi.h>

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SVProgressHUD setBackgroundColor:[UIColor colorNamed:@"Line Color"]];
    [SVProgressHUD setMaximumDismissTimeInterval:2];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [IQKeyboardManager sharedManager].enable = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self loadCartView];
    }];
    
    [WXApi startLogByLevel:WXLogLevelNormal logBlock:^(NSString * _Nonnull log) {
        NSLog(@"WeChat Log: %@", log);
    }];
    
    // WeChatSDK 1.8.2
    [WXApi registerApp:@"wx4c86d73fe4f82431" enableMTA:YES];
    
    // WeChatSDK 1.8.6.1
    //    [WXApi registerApp:@"wx4c86d73fe4f82431" universalLink:@"https://airwallex.com/"];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - UI

- (void)loadCartView
{
    UIViewController *controller = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    [self perform:controller];
}

- (void)perform:(UIViewController *)controller
{
    UIViewController *previousRootViewController = self.window.rootViewController;
    [previousRootViewController dismissViewControllerAnimated:NO completion:^{
        [previousRootViewController.view removeFromSuperview];
    }];
    self.window.rootViewController = controller;
    [UIView transitionWithView:self.window duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.window.rootViewController = controller;
    } completion:nil];
}

#pragma mark - WXApiDelegate

/**
 You can retrieve the payment intent status after your server is notified
 */
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:
                [SVProgressHUD showSuccessWithStatus:@"Succeed to pay"];
                break;
            default:
                [SVProgressHUD showErrorWithStatus:@"Failed to pay"];
                break;
        }
    }
}

@end
