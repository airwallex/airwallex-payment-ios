//
//  AWWebViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/5/18.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWWebViewController.h"
#import <WebKit/WebKit.h>

@interface AWWebViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong, nullable) AWWebHandler webHandler;

@end

@implementation AWWebViewController

- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest webHandler:(AWWebHandler)webHandler
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
    NSString *script = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContent = [[WKUserContentController alloc] init];
    [userContent addUserScript:userScript];

    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContent;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    webView.multipleTouchEnabled = NO;
    webView.navigationDelegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    self.webView = webView;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];

    [self.webView loadRequest:self.urlRequest];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    NSLog(@"%@", url.absoluteString);
    if (url && [url.absoluteString containsString:AWThreeDSReturnURL] && self.webHandler) {
        NSString *payload = [url.absoluteString stringByReplacingOccurrencesOfString:AWThreeDSReturnURL withString:@""];
        self.webHandler(payload, nil);
        [self dismissViewControllerAnimated:YES completion:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.webHandler) {
        self.webHandler(nil, error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.webHandler) {
        self.webHandler(nil, error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
