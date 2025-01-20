//
//  AppDelegate.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AppDelegate.h"
#import "AWXTheme.h"
#import "AirwallexExamplesKeys.h"
#import "Examples-Swift.h"
#import "WXApi.h"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar appearance].barTintColor = [AWXTheme sharedTheme].toolbarColor;
    [UINavigationBar appearance].tintColor = [AWXTheme sharedTheme].tintColor;
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [UIView appearance].tintColor = [AWXTheme sharedTheme].tintColor;
    [UISwitch appearance].onTintColor = [AWXTheme sharedTheme].tintColor;

    [WXApi registerApp:@"wx4c86d73fe4f82431" universalLink:@"https://airwallex.com/"];

    [WXApi startLogByLevel:WXLogLevelNormal
                  logBlock:^(NSString *_Nonnull log) {
                      NSLog(@"WeChat Log: %@", log);
                  }];

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSuccessfullVC" object:nil];
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - WXApiDelegate

/**
 You can retrieve the payment intent status after your server is notified
 */
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        NSString *message = nil;
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
        case WXSuccess:
            message = NSLocalizedString(@"Succeed to pay", nil);
            break;
        case WXErrCodeUserCancel:
            message = NSLocalizedString(@"User cancelled.", nil);
            break;
        default:
            message = NSLocalizedString(@"Failed to pay", nil);
            break;
        }

        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
    }
}

@end
