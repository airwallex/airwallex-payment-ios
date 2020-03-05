//
//  AWViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWViewController.h"

@interface AWViewController ()

@end

@implementation AWViewController

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)unwindToViewController:(UIStoryboardSegue *)unwindSegue
{
}

@end
