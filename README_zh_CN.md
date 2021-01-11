# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-green.svg?style=flat)](https://github.com/Carthage/Carthage)
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
	  * [Carthage](#carthage)
	  * [Swift](#swift)
      * [基本整合](#基本整合)
      * [自定义用法](#自定义用法)
      * [设置微信支付](#设置微信支付)
      * [设置支付宝支付](设置支付宝支付)
      * [主题色](#主题色)
   * [例子](#例子)
   * [贡献](#贡献)
<!--te-->

## 要求
Airwallex iOS SDK需要Xcode 10.0或更高版本，并且与面向iOS 10或更高版本的应用程序兼容。

## 整合

### CocoaPods

Airwallex可通过[CocoaPods](https://cocoapods.org/) 或者 [Carthage](https://github.com/Carthage/Carthage)整合。

如果尚未安装，请安装最新版本的[CocoaPods](https://cocoapods.org/).
如果您还没有`Podfile`, 请运行以下命令来创建一个:
```ruby
pod init
```
将此行添加到您的`Podfile`中:
```ruby
pod 'Airwallex'
```
运行以下命令
```ruby
pod install
```
不要忘记从现在开始使用`.xcworkspace`文件而不是`.xcodeproj`文件来打开项目。
以后如果要更新到最新版本的SDK，只需运行：
```ruby
pod update Airwallex
```

### Carthage

```ogdl
github "airwallex/airwallex-payment-ios"
```

### Swift

即使`Airwallex`是用Objective-C编写的，它也可以轻松地用在Swift中。如果您使用[CocoaPods](https://cocoapods.org/)，请将以下行添加到[Podfile](https://guides.cocoapods.org/using/using-cocoapods.html)中：

```ruby
use_frameworks!
```

### 基本整合

启动应用时，请先配置SDK的`mode`.

```objective-c
[Airwallex setMode:AirwallexSDKLiveMode];
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

- 为用户的服务创建单独的client secret并传入sdk。

```
[AWXCustomerAPIClientConfiguration sharedConfiguration].clientSecret = "The customer's client secret";
```

- 处理付款流程

在结帐界面中，添加一个按钮，让客户输入或更改他们的付款方式。点击后，用`AWXUIContext`显示付款流程。

```objective-c
AWXUIContext *context = [AWXUIContext sharedContext];
context.delegate = ”The target to handle AWXPaymentResultDelegate protocol”;
context.hostViewController = “The host viewController present or push the payment UIs”;
context.paymentIntent = “The payment intent merchant provides”;
context.shipping = “The shipping address merchant provides”;
[context presentPaymentFlow];
```

- 处理付款结果

用户成功完成付款或出现错误后，您需要处理付款结果。

```objective-c
/**
 A delegate which handles checkout results.
 */
@protocol AWXPaymentResultDelegate <NSObject>
 
/**
 This method is called when the user has completed the checkout.
 
 @param controller The controller handling payment result.
 @param status The status of checkout result.
 @param error The error if checkout failed.
 */
- (void)paymentViewController:(UIViewController *)controller didFinishWithStatus:(AWXPaymentStatus)status error:(nullable NSError *)error;
 
/**
 This method is called when the user has completed the checkout with wechat pay.
 
 @param controller The controller handling payment result.
 @param response The wechat object.
 */
- (void)paymentViewController:(UIViewController *)controller nextActionWithWeChatPaySDK:(AWXWeChatPaySDKResponse *)response;
 
@end
```

### 自定义用法

- 自定义物流信息的用法

使用`AWXUIContext`得到`AWXShippingViewController`的实例并显示包含在`UINavigationController`里。

```objective-c
AWXShippingViewController *controller = [AWXUIContext shippingViewController];
controller.delegate = "The target to handle AWXShippingViewControllerDelegate protocol";
controller.shipping = "The shipping address merchant provides";
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:navigationController animated:YES completion:nil];
```

- 处理物流信息的结果

```objective-c
/**
 A delegate which handles selected shipping.
 */
@protocol AWXShippingViewControllerDelegate <NSObject>
 
/**
 This method is called when a shipping has been saved.
 
 @param controller The shipping view controller.
 @param shipping The selected shipping.
 */
- (void)shippingViewController:(AWXShippingViewController *)controller didEditShipping:(AWXPlaceDetails *)shipping;
 
@end
```

- 自定义卡片创建的用法

使用`AWXUIContext`得到`AWXCardViewController`的实例并显示包含在`UINavigationController`里。

```objective-c
AWXCardViewController *controller = [AWXUIContext newCardViewController];
controller.delegate = "The target to handle AWXCardViewControllerDelegate protocol";
controller.customerId = "The customer id merchant provides";
controller.sameAsShipping = YES;
controller.shipping = "The shipping address merchant provides";
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:navigationController animated:YES completion:nil];
```

- 处理卡片创建的结果

```objective-c
/**
 A delegate which handles card creation.
 */
@protocol AWXCardViewControllerDelegate <NSObject>
 
/**
 This method is called when a card has been created and saved to backend.
 
 @param controller The new card view controller.
 @param paymentMethod The saved card.
 */
- (void)cardViewController:(AWXCardViewController *)controller didCreatePaymentMethod:(AWXPaymentMethod *)paymentMethod;
 
@end
```

- 自定义付款明细的用法

使用`AWXUIContext`得到`AWXPaymentViewController`的实例并显示包含在`UINavigationController`里。

```objective-c
AWXPaymentViewController *controller = [AWXUIContext paymentDetailViewController];
controller.delegate = "The target to handle AWXPaymentResultDelegate protocol";
controller.paymentIntent = "The payment intent merchant provides";
controller.paymentMethod = "The payment method merchant provides";
UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
[self presentViewController:navigationController animated:YES completion:nil];
```

- 自定义确认payment intent的用法

在使用`AWXAPIClient`发送请求之前，请设置client secret。

```objective-c
[AWXAPIClientConfiguration sharedConfiguration].clientSecret = "The client secret merchant provides";
```

```objective-c
AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
request.intentId = "The payment intent id merchant provides";
request.paymentMethod = "The payment method merchant provides";
AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
options.autoCapture = YES;
options.threeDsOption = NO;
request.options = options;
request.requestId = NSUUID.UUID.UUIDString;

AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
[client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
	if (error) {
		return;
	}
 
	AWXConfirmPaymentIntentResponse *result = (AWXConfirmPaymentIntentResponse *)response;
	// Handle the payment result.
}];
```

- 自定义3DS流程

```
AWXThreeDSService *service = [AWXThreeDSService new];
service.customerId = "The customer id merchant provides";
service.intentId = "The intent id merchant provides";
service.paymentMethod = "The payment method merchant provides";
service.device = "The device id got by AWXSecurityService";
service.presentingViewController = “The host viewController present or push the payment UIs”;
service.delegate = ”The target to handle AWXThreeDSServiceDelegate protocol”;
[service presentThreeDSFlowWithServerJwt:"The server jwt backend provides"];
```

- 处理3DS的结果

```objective-c
/**
 A delegate which handles 3ds results.
 */
@protocol AWXThreeDSServiceDelegate <NSObject>

/**
 This method is called when the user has completed the 3ds flow.
 
 @param service The service handling 3ds flow.
 @param response The response of 3ds auth.
 @param error The error if 3ds auth failed.
 */
- (void)threeDSService:(AWXThreeDSService *)service
 didFinishWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response
                 error:(nullable NSError *)error;

@end
```

### 设置微信支付

注意：您可以按照此官方指南来设置[WeChat In-App Pay](https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=8_5)。

1. 商家成功在微信开放平台上申请了应用后，平台将向商家提供唯一的APPID。在Xcode中创建项目时，开发人员应在“URL Schemes”字段中输入APPID值。
2. 在调用API之前，您应该在微信上注册您的APPID。

```objective-c
[WXApi registerApp:@"Wechat app id" enableMTA:YES];
```

3. 商家的服务器调用统一订单API来创建交易。获取prepay_id并签署相关参数后，交易数据将传输到该应用以开始付款。

```objective-c
- (void)paymentWithWechatPaySDK:(AWXWeChatPaySDKResponse *)response
{
	PayReq *request = [[PayReq alloc] init];
	request.partnerId = response.partnerId;
	request.prepayId = response.prepayId;
	request.package = response.package;
	request.nonceStr = response.nonceStr;
	request.timeStamp = response.timeStamp.doubleValue;
	request.sign = response.sign;

	[WXApi sendReq:request];
}
```

4. 付款完成后，微信将重定向到商家的应用程序，并使用onRes()进行回调，然后在通知商家服务器后可以检索payment intent状态，因此请保持监听通知。

```objective-c
- (void)onResp:(BaseResp *)resp
{
	if ([resp isKindOfClass:[PayResp class]]) {
		PayResp *response = (PayResp *)resp;
		switch (response.errCode) {
			case WXSuccess:
				[SVProgressHUD showSuccessWithStatus:@"Succeed to pay"];
				break;
			default:
				[SVProgressHUD showErrorWithStatus:@"Failed to pay"];
				break;
		}
	}
}
```

### 设置支付宝支付

处理从服务端返回的URL来完成支付。

```objective-c
- (void)paymentViewController:(UIViewController *)controller nextActionWithAlipayURL:(NSURL *)url
{
    [controller dismissViewControllerAnimated:YES completion:^{
        SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:url];
        webViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:webViewController animated:YES completion:nil];
    }];
}
```

### 主题色

你可以通过下面代码自定义主题色。

```
UIColor *tintColor = [UIColor colorWithRed:97.0f/255.0f green:47.0f/255.0f blue:255.0f/255.0f alpha:1];
[AWXTheme sharedTheme].tintColor = tintColor;
[UIView.appearance setTintColor:tintColor];
```

## 例子

要运行示例项目，应遵循以下步骤。

- 准备

1. 安装Xcode的[最新版本](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).

2. 安装[Bundle](https://bundler.io/)

```ruby
gem install bundler
```

- 克隆源代码

运行以下脚本将该项目克隆到本地磁盘。

```
git clone git@github.com:airwallex/airwallex-payment-ios.git
```

- 安装依赖项并打开项目

1. 进入项目目录

```
cd airwallex-payment-ios
```

2. 安装依赖

```
bundle install
```

```
pod install
```

3. 使用Xcode打开`Airwallex.xcworkspace`或者运行以下脚本。 **确保始终通过work space打开项目**

```
open Airwallex.xcworkspace
```

- 构建配置

有两种配置`Airwallex`和`Examples`。你可以在项目中切换你想要的配置。

`Airwallex`将为开发人员生成框架

`Examples`将构建和运行示例应用程序

- 在iOS设备上运行该应用

从左上方的面板中选择目标设备，然后按键盘上的“ Command + R”（或从顶部菜单栏中的“产品>运行”）在iOS设备上运行此项目。

## 贡献

我们欢迎任何形式的贡献，包括新功能，错误修复和文档改进。最好的贡献方式是提交请求 - 我们将尽快回复您的提交。如果您发现错误或有任何疑问，也可以提交问题。
