# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)

Airwallex iOS SDK是一个框架，通过它可以在您的应用程序中轻松，快速和安全地完成付款。它提供了简单的功能，可以将敏感的信用卡数据直接发送到Airwallex，还提供了功能详细的界面，用于收集用户付款明细。

<p align="left">
<img src="https://github.com/user-attachments/assets/e1c3f540-6cbb-4711-b392-24bbbdb7b779" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/9ed00d30-fd45-4882-b6d0-e2171c64e0fb" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/0645ba1a-8cf1-4811-ba6f-c0b0f9589b98" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/121f98d8-9944-4254-80b6-9f39d945c4c8" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/9812c275-cb88-4835-a5e4-77bfa3b05319" width="200" hspace="10">
</p>

开始使用我们的集成指南和示例项目。

目录
=================

<!--ts-->
   * [要求](#要求)
   * [集成](#集成)
      * [CocoaPods](#cocoapods)
	  * [Swift](#swift)
      * [基础集成](#基础集成)
      * [低层API集成](#低层API集成)
      * [设置微信支付](#设置微信支付)
      * [设置 Apple Pay](#设置-Apple-Pay)
      * [主题色](#主题色)
   * [例子](#例子)
   * [贡献](#贡献)
<!--te-->

## 要求
Airwallex iOS SDK 支持 iOS 13.0 及以上版本。并且需要 XCode 15.4 及以上版本编译运行，如果是老版本Xcode请参照之前发布的版本 [5.4.3](https://github.com/airwallex/airwallex-payment-ios/releases/tag/5.4.3)。

## 集成

### CocoaPods

Airwallex可通过[CocoaPods](https://cocoapods.org/) 集成。

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
### Swift Package Manager
Airwallex for iOS 可以通过 Swift 包管理器获取。要将其集成到您的项目中，请按照以下步骤操作：
1. 添加包依赖
请[参阅 Apple 的指南](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)了解如何在 Xcode 中添加包依赖。
2. 仓库 URL
使用以下 URL 获取 Airwallex 包：
https://github.com/airwallex/airwallex-payment-ios
3. 版本要求
确保您指定的版本为 5.7.0 或更高版本。

### 可集成的组件
您可以添加 `Airwallex` 以包含所有组件，或者根据您的支付需求，有选择地将以下组件添加到您的项目中：

- `AirwallexApplePay`: 用于集成 Apple Pay。
- `AirwallexCard`: 用于卡支付服务。
- `AirwallexRedirect`: 支持通过 url/deeplink 重定向进行支付。
- `AirwallexWechatPay`: 提供本地化的微信支付体验。

### Swift

即使`Airwallex`是用Objective-C编写的，它也可以轻松地用在Swift中。如果您使用[CocoaPods](https://cocoapods.org/)，请将以下行添加到[Podfile](https://guides.cocoapods.org/using/using-cocoapods.html)中：

```ruby
use_frameworks!
```

### 基础集成

这是**推荐用法**, 它通过我们已经为你构建好的UI创建出一个完整的用户流程，以便于收集支付详情、账单详情和确认支付。

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
session.hidePaymentConsents = "Whether the stored cards should be hidden on the list (Default NO)"
session.paymentMethods = "An array of payment method type names" (Optional)
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
session.paymentMethods = "An array of payment method type names" (Optional)
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
session.paymentMethods = "An array of payment method type names" (Optional)
```

- 显示付款流程

在结帐界面中，添加一个按钮，让客户输入或更改他们的付款方式。点击后，用`AWXUIContext`显示付款流程。

```objective-c
AWXUIContext *context = [AWXUIContext sharedContext];
context.delegate = ”The target to handle AWXPaymentResultDelegate protocol”;
context.session = session;
[context presentEntirePaymentFlowFrom:self];
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

如果有需要，可以通过以下可选方法获取consent id，以便之后的支付使用。
```objective-c
- (void)paymentViewController:(UIViewController *)controller didCompleteWithPaymentConsentId:(NSString *)Id {
    // To do anything with this id.
}
```

### 低层API集成

你可以基于我们的低层API来构建完全由你自定义的UI

#### 用卡和账单详情或者payment consent来确认卡支付

你仍然需要按照[基础集成](#基础集成)中的步骤来设置配置、intent和session, 除了**显示付款流程**的步骤由以下步骤代替:

```objective-c
AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:"The target to handle AWXPaymentResultDelegate protocol" session:"The session created above"];
// After initialization, you will need to store the provider in your view controller or class that is tied to your view's lifecycle
self.provider = provider;

// Confirm intent with card and billing
[provider confirmPaymentIntentWithCard:"The AWXCard object collected by your custom UI" billing:"The AWXPlaceDetails object collected by your custom UI" saveCard:"Whether you want the card to be saved as payment consent for future payments"];

// Confirm intent with a payment consent object (AWXPaymentConsent)
[provider confirmPaymentIntentWithPaymentConsent:paymentConsent];

// Confirm intent with a valid payment consent ID only when the saved card is **network token**
[provider confirmPaymentIntentWithPaymentConsentId:@"cst_xxxxxxxxxx"];
``` 

你也需要提供你的顶栈控制器，我们会在此之上来展示额外的用户页（例如3DS校验页、警示页）
```objective-c
#pragma mark - AWXProviderDelegate

- (UIViewController *)hostViewController {
    // Your host view controller
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    // You can handle different payment statuses and perform UI action respectively here
}
```

如果有需要，可以通过以下可选方法获取consent id，以便之后的支付使用。

```objective-c
- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)Id {
    // To do anything with this id.
}
```

#### 用Apple Pay provider或Redirect provider来发起支付

你仍然需要按照[基础集成](#基础集成)中的步骤来设置配置、intent和session, 除了**显示付款流程**的步骤由以下步骤代替:

```objective-c
AWXApplePayProvider *provider = [[AWXApplePayProvider alloc] initWithDelegate:"The target to handle AWXProviderDelegate protocol" session:"The one off session created with apple pay options"];
// AWXRedirectActionProvider *provider = [[AWXRedirectActionProvider alloc] initWithDelegate:"The target to handle AWXProviderDelegate protocol" session:"The one off session created"];

// After initialization, you will need to store the provider in your view controller or class that is tied to your view's lifecycle
self.provider = provider;

// Initiate the apple pay flow
 [provider startPayment];
// Confirm intent with a valid payment method name that supports redirect pay
// [provider confirmPaymentIntentWithPaymentMethodName:@"payment method name"];

``` 

你需要实现以下delegate方法来处理支付结果
```objective-c
#pragma mark - AWXProviderDelegate

- (void)provider:(nonnull AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    switch (status) {
    case AirwallexPaymentStatusSuccess:
       // handle success
        break;
    case AirwallexPaymentStatusFailure:
       // handle failure
        break;
    case AirwallexPaymentStatusCancel:
       // handle Apple Pay cancelled by the user
        break;
    default:
        break;
    }
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
- Amex
- Discover
- JCB

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

在 `Examples/Keys` 目录下，编辑并更新 `Keys.json` 文件。

- 编译启动 `Example` 应用

如果没有更新密钥文件，你也可以通过实例应用里的设置界面配置 API 密钥。请确保点击 `Generate customer` 按钮然后再执行 Checkout。

## 贡献

我们欢迎任何形式的贡献，包括新功能，错误修复和文档改进。最好的贡献方式是提交请求 - 我们将尽快回复您的提交。如果您发现错误或有任何疑问，也可以提交问题。
