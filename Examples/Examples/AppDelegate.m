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
#import "WXApi.h"

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SVProgressHUD setBackgroundColor:[UIColor colorNamed:@"Line Color"]];
    [SVProgressHUD setMaximumDismissTimeInterval:1];
    [IQKeyboardManager sharedManager].enable = YES;
    
    [WXApi startLogByLevel:WXLogLevelNormal logBlock:^(NSString * _Nonnull log) {
        NSLog(@"WeChat Log: %@", log);
    }];

    // WeChatSDK 1.8.2
    [WXApi registerApp:@"wxfad13fd6681a62b0" enableMTA:YES];

    // WeChatSDK 1.8.6.1
//    [WXApi registerApp:@"wxfad13fd6681a62b0" universalLink:@"https://airwallex.com/"];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:
                [SVProgressHUD showSuccessWithStatus:@"Succeed to pay"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PaymentCompleted" object:nil];
                break;
            default:
                [SVProgressHUD showErrorWithStatus:@"Failed to pay"];
                break;
        }
    }
}

@end
