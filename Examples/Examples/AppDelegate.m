//
//  AppDelegate.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AppDelegate.h"
#import <Airwallex/UI.h>
#import <WechatOpenSDK/WXApi.h>
#import "AirwallexExamplesKeys.h"

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WXApi registerApp:@"wx4c86d73fe4f82431" universalLink:@"https://airwallex.com/"];
    
    [WXApi startLogByLevel:WXLogLevelNormal logBlock:^(NSString * _Nonnull log) {
        NSLog(@"WeChat Log: %@", log);
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self loadCartView];
    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSuccessfullVC" object:nil];
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
        NSString *message = nil;
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:
                message = @"Succeed to pay";
                break;
            default:
                message = @"Failed to pay";
                break;
        }
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
        [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
    }
}

@end
