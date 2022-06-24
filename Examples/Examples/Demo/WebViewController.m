//
//  WebViewController.m
//  Examples
//
//  Created by Victor Zhu on 2021/5/13.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat SCREEN_WIDTH = [[UIScreen mainScreen] bounds].size.width;
    CGFloat SCREEN_HEIGHT = [[UIScreen mainScreen] bounds].size.height;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
    [self.view addSubview:self.webView];
    [self.webView addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptionNew)context:nil];
    [self load];
}

- (void)load {
    if (self.url.length) {
        NSURL *url = [NSURL URLWithString:self.url];
        NSMutableURLRequest *requeset = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        NSURL *referUrl = [NSURL URLWithString:self.referer];
        if (referUrl) {
            NSString *host = referUrl.host;
            self.referer = [NSString stringWithFormat:@"%@://", host];
        }
        [requeset setValue:self.referer forHTTPHeaderField:@"Referer"];
        [requeset setValue:@"Airwallex-iOS-SDK" forHTTPHeaderField:@"User-Agent"];
        [requeset setHTTPMethod:@"GET"];
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        [self.webView loadRequest:requeset];
        //设置ua会造成微信支付 cancel 无法返回
        //        [self setWebViewUA];
    }
}

- (void)setWebViewUA {
    [self.webView evaluateJavaScript:@"navigator.userAgent"
                   completionHandler:^(id result, NSError *error) {
                       NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Airwallex-iOS-SDK", @"UserAgent", nil];
                       [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
                       [[NSUserDefaults standardUserDefaults] synchronize];
                   }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *absoluteString = navigationAction.request.URL.absoluteString;
    if (([absoluteString hasPrefix:@"weixin://wap/pay?"] ||
         [absoluteString hasPrefix:@"alipay://"] ||
         [absoluteString hasPrefix:@"alipayhk://"] ||
         [absoluteString hasPrefix:@"airwallexcheckout://"] ||
         [absoluteString hasPrefix:@"alipays://"]) &&
        !([absoluteString hasPrefix:@"http://"] || [absoluteString hasPrefix:@"https://"])) {
        NSURL *url = [[NSURL alloc] initWithString:absoluteString];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    }
}

@end
