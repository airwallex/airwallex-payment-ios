# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

- [API Reference](https://airwallex.github.io/airwallex-payment-ios/)

Airwallex iOS SDK是一个框架，通过它可以在您的应用程序中轻松，快速和安全地完成付款。它提供了简单的功能，可以将敏感的信用卡数据直接发送到Airwallex，还提供了功能详细的界面，用于收集用户付款明细。

<p align="center">
<img src="./Screenshots/shipping.png" width="200" alt="AWXShippingViewController" hspace="10">
<img src="./Screenshots/card.png" width="200" alt="AWXCardViewController" hspace="10">
<img src="./Screenshots/payment method list.png" width="200" alt="AWXPaymentMethodListViewController" hspace="10">
<img src="./Screenshots/payment.png" width="200" alt="AWXPaymentViewController" hspace="10">
</p>

开始使用我们的集成指南和示例项目。

目录
=================

<!--ts-->
   * [要求](#要求)
   * [整合](#整合)
      * [CocoaPods](#cocoapods)
	  * [Swift](#swift)
      * [基本整合](#基本整合)
      * [设置微信支付](#设置微信支付)
      * [设置 Apple Pay](#设置-Apple-Pay)
      * [主题色](#主题色)
   * [例子](#例子)
   * [贡献](#贡献)
<!--te-->

## 要求
Airwallex iOS SDK 支持 iOS 11.0 及以上版本。

## 整合

### CocoaPods

Airwallex可通过[CocoaPods](https://cocoapods.org/) 整合。

将此行添加到您的`Podfile`中：
```ruby
pod 'Airwallex'
```

或者，你也可以选择直接安装可选模组（最小化依赖）：

```ruby
pod 'Airwallex/Core'
pod 'Airwallex/Card'
pod 'Airwallex/WechatPay'
pod 'Airwallex/Redirect'
pod 'Airwallex/ApplePay'
```

运行以下命令：
```ruby
pod install
```

### Swift

即使`Airwallex`是用Objective-C编写的，它也可以轻松地用在Swift中。如果您使用[CocoaPods](https://cocoapods.org/)，请将以下行添加到[Podfile](https://guides.cocoapods.org/using/using-cocoapods.html)中：

```ruby
use_frameworks!
```

### 基本整合

启动应用时，请先配置SDK的`mode`.

```objective-c
[Airwallex setMode:AirwallexSDKStagingMode]; // AirwallexSDKDemoMode, AirwallexSDKStagingMode, AirwallexSDKProductionMode
```

如果你想在不同的服务端进行测试，你可以自定义mode和payment URL.

```objective-c
[Airwallex setDefaultBaseURL:[NSURL URLWithString:@”Airwallex payment base URL”]];
```

- 创建payment intent

当客户想要结帐时，您应该在服务器端创建payment intent，然后将payment intent传递给移动端，以所选的付款方式确认payment intent。

```
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The payment intent's client secret";
```
注:  当checkoutMode 为AirwallexCheckoutRecurringMode时,我们不需要创建 payment intent,这时你需要使用customer id来创建client secret并传入AWXAPIClientConfiguration。
```
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The client secret generated with customer id";
```

- 创建session

如果你想完成一次性支付，请创建一次性支付的session。
```
AWXOneOffSession *session = [AWXOneOffSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
```

如果你想完成订阅，请创建订阅session.
```
AWXRecurringSession *session = [AWXRecurringSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.currency = "Currency code";
session.amount = "Total amount";
session.customerId = "Customer id";
session.nextTriggerByType = "customer or merchant";
session.requiresCVC = "Whether it requires CVC (Default NO)";
session.merchantTriggerReason = "Unscheduled or scheduled";
```

如果你想完成特定payment intent的订阅，请使用payment intent创建session。
```
AWXRecurringWithIntentSession *session = [AWXRecurringWithIntentSession new];
session.countryCode = "Your country code";
session.billing = "Your shipping address";
session.returnURL = "App return url";
session.paymentIntent = "Payment intent";
session.autoCapture = "Whether the card payment will be captured automatically (Default YES)";
session.nextTriggerByType = "customer or merchant";
session.requiresCVC = "Whether it requires CVC (Default NO)";
session.merchantTriggerReason = "Unscheduled or scheduled";
```

- 处理付款流程

在结帐界面中，添加一个按钮，让客户输入或更改他们的付款方式。点击后，用`AWXUIContext`显示付款流程。

```objective-c
AWXUIContext *context = [AWXUIContext sharedContext];
context.delegate = ”The target to handle AWXPaymentResultDelegate protocol”;
context.session = session;
[context presentPaymentFlowFrom:self];
```

- 处理付款结果

用户成功完成付款或出现错误后，您需要处理付款结果。

```objective-c
#pragma mark - AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *)controller didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        // Status may be success/in progress/ failure / cancel
    }];
}
```

### 设置微信支付

付款完成后，微信将重定向到商家的应用程序，并使用onRes()进行回调，然后在通知商家服务器后可以检索payment intent状态，因此请保持监听通知。

```objective-c
@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WXApi registerApp:@"WeChat app id" universalLink:@"https://airwallex.com/"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

/**
 You can retrieve the payment intent status after your server is notified
 */
- (void)onResp:(BaseResp *)resp
{
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
```

### 设置 Apple Pay

Airwallex iOS SDK 允许商户向客户提供 Apple Pay 作为付款方式。

- 首先确保 Apple Pay 已在应用中开启并配置。请参考 Apple 的[官方文档](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay).
- 确保 Apple Pay 已在您的 Airallex 账户中开启。
- 安装 Airwallex iOS SDK 时添加 Apple Pay 模组。
- 生成 [Merchant Identifier](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay) 并配置 `applePayOptions`。

完成上述步骤后，Apple Pay 会作为一种选项出现在付款方式列表里。

```objective-c
AWXOneOffSession *session = [AWXOneOffSession new];
...
... configure other properties
...

session.applePayOptions = [[AWXApplePayOptions alloc] initWithMerchantIdentifier:@"Merchant Identifier"];
```

> 请注意，Apple Pay 目前仅支持 `AWXOneOffSession` 一次性支付。我们将在以后添加对订阅支付的支持。

#### 自定义 Apple Pay

你也可以自定义 Apple Pay 选项来限制支付场景和提供额外的信息。请参考 `AWXApplePayOptions.h` 头文件以获取更多信息。

```
AWXApplePayOptions *options = ...;
options.additionalPaymentSummaryItems = @[
    [PKPaymentSummaryItem summaryItemWithLabel:@"goods" amount:[NSDecimalNumber decimalNumberWithString:@"10"]],
    [PKPaymentSummaryItem summaryItemWithLabel:@"tax" amount:[NSDecimalNumber decimalNumberWithString:@"5"]]
];
options.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityDebit;
options.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldPostalAddress, nil];
options.supportedCountries = [NSSet setWithObjects:@"AU", nil];
options.totalPriceLabel = @"COMPANY, INC.";
```

#### 限制

目前 Apple Pay 我们支持以下几种支付系统：
- Visa
- MasterCard
- ChinaUnionPay
- Maestro (iOS 12+)

用户在 Apple Pay 的过程中只能选择这几种支付系统的卡片进行付款。

优惠卷也暂时不支持。

### 主题色

你可以通过下面代码自定义主题色。

```
UIColor *tintColor = [UIColor colorWithRed:97.0f/255.0f green:47.0f/255.0f blue:255.0f/255.0f alpha:1];
[AWXTheme sharedTheme].tintColor = tintColor;
[UIView.appearance setTintColor:tintColor];
```

## 示例

示例应用支持最新版的 Xcode。要运行示例项目，应遵循以下步骤。

- 克隆源代码

运行以下脚本将该项目克隆到本地磁盘。

```
git clone git@github.com:airwallex/airwallex-payment-ios.git
```

- 安装依赖项并打开项目

确保已经安装 Cocoapods，然后在项目目录下执行以下命令：

```
pod install
```

- 配置 API 密钥（可选）

在 `Examples/Keys` 目录下，编辑并更新 `Keys_sample.json` 文件，然后重命名为 `Keys.json`。

- 编译启动 `Example` 应用

如果没有更新密钥文件，你也可以通过实例应用里的设置界面配置 API 密钥。请确保点击 `Generate customer` 按钮然后再执行 Checkout。

## 贡献

我们欢迎任何形式的贡献，包括新功能，错误修复和文档改进。最好的贡献方式是提交请求 - 我们将尽快回复您的提交。如果您发现错误或有任何疑问，也可以提交问题。
