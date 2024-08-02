//
//  AWX3DSViewController.m
//  Card
//
//  Created by Victor Zhu on 2022/1/5.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWX3DSViewController.h"
#import "AWXAnalyticsLogger.h"
#import "AWXConstants.h"
#import "AWXUtils.h"
#import <WebKit/WebKit.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWX3DSViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *HTMLString;
@property (nonatomic, strong) NSString *stage;
@property (nonatomic, strong, nullable) AWXWebHandler webHandler;

@end

@implementation AWX3DSViewController

- (NSString *)pageName {
    return @"webview_redirect";
}

- (NSDictionary<NSString *, id> *)additionalInfo {
    NSMutableDictionary *info = [NSMutableDictionary new];
    if (_stage.length > 0) {
        [info setObject:_stage forKey:@"stage"];
    }
    return info;
}

- (instancetype)initWithHTMLString:(NSString *)HTMLString stage:(NSString *)stage webHandler:(AWXWebHandler)webHandler {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _HTMLString = HTMLString;
        _stage = stage;
        _webHandler = webHandler;
        if (@available(iOS 13.0, *)) {
            self.modalInPresentation = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
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
    webView.UIDelegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    self.webView = webView;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];

    [self.webView loadHTMLString:self.HTMLString baseURL:nil];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (self.webHandler) {
                                     self.webHandler(nil, [NSError errorForAirwallexSDKWith:-1 localizedDescription:NSLocalizedString(@"User cancelled.", nil)]);
                                 }
                             }];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if (url && [url.absoluteString hasPrefix:AWXThreeDSReturnURL] && self.webHandler) {
        NSString *response = [[NSString alloc] initWithData:navigationAction.request.HTTPBody encoding:NSUTF8StringEncoding];
        if ([self.stage isEqualToString:AWXThreeDSWatingDeviceDataCollection]) {
            self.webHandler(response, nil);
        } else {
            [self dismissViewControllerAnimated:YES
                                     completion:^{
                                         self.webHandler(response, nil);
                                     }];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    if (response.statusCode == 400) {
        if ([self.stage isEqualToString:AWXThreeDSWatingDeviceDataCollection]) {
            self.webHandler(nil, [NSError errorForAirwallexSDKWith:-1 localizedDescription:NSLocalizedString(@"Unknown issue.", nil)]);
        } else {
            [self dismissViewControllerAnimated:YES
                                     completion:^{
                                         self.webHandler(nil, [NSError errorForAirwallexSDKWith:-1 localizedDescription:NSLocalizedString(@"Unknown issue.", nil)]);
                                     }];
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [[AWXAnalyticsLogger shared] logError:error withEventName:@"webview_redirect"];

    if (error.code == 102) {
        return;
    }

    if ([self.stage isEqualToString:AWXThreeDSWatingDeviceDataCollection]) {
        self.webHandler(nil, error);
    } else {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     self.webHandler(nil, error);
                                 }];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [[AWXAnalyticsLogger shared] logError:error withEventName:@"webview_redirect"];

    if ([self.stage isEqualToString:AWXThreeDSWatingDeviceDataCollection]) {
        self.webHandler(nil, error);
    } else {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     self.webHandler(nil, error);
                                 }];
    }
}

@end
