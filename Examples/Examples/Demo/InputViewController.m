//
//  InputViewController.m
//  Examples
//
//  Created by Victor Zhu on 2021/5/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "InputViewController.h"
#import "WebViewController.h"
#import "SuccessViewController.h"

#import <WebKit/WebKit.h>

@interface InputViewController ()
@property (weak, nonatomic) IBOutlet UITextField *url1TextField;
@property (weak, nonatomic) IBOutlet UITextField *url2TextField;
@property(nonatomic,strong) WebViewController *webView;
@end

@implementation InputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showSuccessfull) name:@"showSuccessfullVC" object:nil];
}

- (IBAction)btnTapped:(id)sender {
    if (!self.url1TextField.text.length || !self.url2TextField.text.length) {
        [self showTip];
        return;
    }
    WebViewController *webview = [[WebViewController alloc]init];
    webview.url = self.url1TextField.text;
    webview.referer = self.url2TextField.text;
    [self.navigationController pushViewController:webview animated:YES];
    self.webView = webview;
}

-(void)showTip {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please fill in all the fields" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Sure" style:(UIAlertActionStyleDefault) handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showSuccessfull{
    if (self.webView) {
        [self.webView.navigationController popViewControllerAnimated:false];
    }
    SuccessViewController *vc = [[SuccessViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
