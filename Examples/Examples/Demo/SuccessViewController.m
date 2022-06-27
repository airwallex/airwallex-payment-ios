//
//  SuccessViewController.m
//  Examples
//
//  Created by Victor Zhu on 2021/5/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "SuccessViewController.h"
#import "Airwallex/Core.h"

@interface SuccessViewController ()

@end

@implementation SuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;

    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    lab.center = self.view.center;
    lab.text = @"Pay Result";
    lab.textColor = [AWXTheme sharedTheme].primaryTextColor;
    lab.font = [UIFont systemFontOfSize:30];
    lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab];
}

@end
