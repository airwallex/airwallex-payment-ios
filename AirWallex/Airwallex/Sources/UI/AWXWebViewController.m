//
//  AWXWebViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/5/18.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXWebViewController.h"
#import <WebKit/WebKit.h>
#import "AWXUtils.h"

@interface AWXWebViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong, nullable) AWXWebHandler webHandler;

@end

@implementation AWXWebViewController

- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest webHandler:(AWXWebHandler)webHandler
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _urlRequest = urlRequest;
        _webHandler = webHandler;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *script = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContent = [[WKUserContentController alloc] init];
    [userContent addUserScript:userScript];
    
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContent;
    configuration.preferences.javaScriptEnabled = YES;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    webView.multipleTouchEnabled = NO;
    webView.navigationDelegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    self.webView = webView;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    
    [self.webView loadRequest:self.urlRequest];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.webHandler) {
            self.webHandler(nil, [NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"User cancelled."}]);
        }
    }];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    if (url && [url.absoluteString containsString:AWXRedirectPaResURL] && self.webHandler) {
        NSString *paRes = [url queryValueForName:@"paRes"];
        [self dismissViewControllerAnimated:YES completion:^{
            self.webHandler(paRes, nil);
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code == 102) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.webHandler) {
            self.webHandler(nil, error);
        }
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.webHandler) {
            self.webHandler(nil, error);
        }
    }];
}

@end
