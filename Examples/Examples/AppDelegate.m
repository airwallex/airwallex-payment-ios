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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SVProgressHUD setBackgroundColor:[UIColor colorNamed:@"Line Color"]];
    [SVProgressHUD setMaximumDismissTimeInterval:1];
    [IQKeyboardManager sharedManager].enable = YES;
    return YES;
}

@end
