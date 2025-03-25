# Airwallex iOS SDK

![Pod Version](https://img.shields.io/cocoapods/v/Airwallex.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/Airwallex.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/Airwallex.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)


## 概述

Airwallex iOS SDK 是一个框架，用于在您的应用中集成简单、快速和安全的支付功能。它提供了简单的功能，可以将敏感的信用卡数据直接发送到 Airwallex，同时还提供了一个强大且可定制的界面，用于收集用户的支付详情。

<p align="left">
<img src="https://github.com/user-attachments/assets/babf2af3-d59b-49fc-8b86-26e85df28a0c" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/c86b7f3f-d2bc-4326-b82e-145f52d35c72" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/938e6101-edb2-4fcf-89fa-07936e4af5a9" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/5556a6af-882d-4474-915e-2c9d5953aaa8" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/eb6f0b38-d88b-4c27-b843-9948bc25c5a0" width="200" hspace="10">
<img src="https://github.com/user-attachments/assets/1de983a9-b062-4108-82f5-917e0fc0fb57" width="200" hspace="10">
</p>

目录
<!--ts-->

- [开始集成](#开始集成)
- [要求](#要求)
- [示例项目](#示例项目)
- [集成步骤](#集成步骤)
  - [安装](#安装)
    - [Swift Package Manager](#swift-package-manager)
    - [CocoaPods](#cocoapods)
  - [必要设置](#必要设置)
    - [Customer ID](#customer-id)
    - [创建 `AWXSession`](#创建-awxsession)
    - [创建 `AWXPaymentIntent`](#创建-awxpaymentintent)
    - [设置客户端密钥](#设置客户端密钥)
  - [可选设置](#可选设置)
    - [微信支付](#微信支付)
    - [Apple Pay](#apple-pay)
  - [UI 集成](#ui-集成)
    - [启动完整支付列表（推荐）](#启动完整支付列表推荐)
    - [仅展示卡支付](#仅展示卡支付)
    - [按名称启动支付方式](#按名称启动支付方式)
    - [自定义主题色](#自定义主题色)
  - [Low-level API 集成](#low-level-api-集成)
    - [创建 PaymentSessionHandler](#创-paymentsessionhandler)
    - [使用卡支付](#使用卡支付)
    - [使用保存的卡支](#使用保存的卡支)
    - [使用 Apple Pay 支付](#使用-apple-pay-支付)
    - [使用跳转支付](#使用跳转支付)
  - [处理支付结果](#处理支付结果)
- [贡献](#贡献)
<!--te-->
=================
## 开始集成
请按照我们的[集成指南](#integration)并探索[示例项目](#examples)，以快速使用 Airwallex SDK 设置支付功能。
> [!TIP] 
> 从旧版 SDK 升级的相关改动可以参考我们的[迁移文档](MIGRATION.md)

## 要求
- iOS 13.0+
- Xcode 15.4+（对于旧版本的 Xcode，请参考 5.4.3 版本）

## 示例项目

示例可以在最新的 Xcode 上运行。要运行示例应用程序，请按照以下步骤操作。

- 克隆源代码

```
git clone git@github.com:airwallex/airwallex-payment-ios.git
```

- 安装依赖并打开项目

确保已安装 Cocoapods，然后在项目目录中运行以下命令：

```
pod install
```

> [!TIP] 更新初始化设置文件（可选）
>
>- 更新 `Examples/Keys` 文件夹中的 `Keys.json`。
>- 构建并运行 `Examples` 
>
> 您可以随时使用应用内的设置页面更改这些设置

## 集成步骤

### 安装

#### Swift Package Manager
Airwallex iOS SDK 支持 Swift Package Manager 。要将其集成到您的项目中，请按照以下步骤操作：
1. 添加包依赖
[按照 Apple 的指南添加包依赖。](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)
2. 代码仓库 URL
使用以下 URL 获取 Airwallex 包：
https://github.com/airwallex/airwallex-payment-ios
3. 版本要求
确保指定 5.7.0 或更高版本。

您可以添加 `Airwallex` 以包含所有组件，或者根据您的支付需求选择性地将以下组件添加到您的项目中：

- `AirwallexPayment`: 用于 UI 集成。
- `AirwallexApplePay`: 用于集成 Apple Pay。
- `AirwallexCard`: 用于卡支付。
- `AirwallexRedirect`: 支持通过 URL/deeplink 重定向支付。
- `AirwallexWeChatpay`: 用于原生微信支付体验。
---
#### CocoaPods

Airwallex iOS SDK 可以通过 [CocoaPods](https://cocoapods.org/) 获取。

在您的 `Podfile` 中添加以下行：
```ruby
pod 'Airwallex'
```

您也可以直接指定 `subspec` 来避免引入不需要的依赖：

```ruby
pod 'Airwallex/Payment'
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
### 必要设置

当您的应用启动时，使用 `mode` 配置 SDK。

``` swift
Airwallex.setMode(.demoMode) // .demoMode, .stagingMode, .productionMode
```
---
#### Customer ID 
> [!IMPORTANT]
> **订阅支付**或**带intent订阅支付** 必须绑定 customer ID
> 
> **一次性支付** 可以不绑定 customer ID
>
在您的服务器端为您的用户生成或检索 customer ID。
相关接口信息，请参阅[Airwallex API 文档](https://www.airwallex.com/docs/api#/Payment_Acceptance/Customers/)

---
#### 创建 `AWXSession`

- 如果您想进行一次性支付，请创建 `AWXOneOffSession`。
``` swift
let session = AWXOneOffSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
```
- 如果您想进行订阅支付，请创建 `AWXRecurringSession`。
``` swift
let session = AWXRecurringSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
session.setCurrency("Currency code")
session.setAmount("Total amount")
session.setCustomerId("Customer ID")
session.nextTriggerByType = "customer or merchant";
session.merchantTriggerReason = "Unscheduled or scheduled";
```
- 如果你想完成带 payment intent 的订阅支付，请创建 `AWXRecurringWithIntentSession`。

``` swift
let session = AWXRecurringWithIntentSession()
session.countryCode = "Your country code"
session.billing = "Your shipping address"
session.returnURL = "App return url"
session.nextTriggerByType = "customer or merchant"
session.merchantTriggerReason = "Unscheduled or scheduled"
```
> [!TIP] 
> 您只需为订阅支付（`AWXRecurringSession`）显式设置客户 ID。
> 对于**一次性支付**和**带 intent 的订阅支付**，会自动从 `session.paymentIntent` 中获取 customer ID。

---
#### 创建 `AWXPaymentIntent`
> [!IMPORTANT]
> **一次性支付**或**带 intent 订阅支付**结账前必须创建 `AWXPaymentIntent`。
>
> **订阅支付**不需要创建`AWXPaymentIntent`。
> 

在您的服务器端创建**payment intent**，然后将payment intent返回到移动端。

相关接口信息，请参阅 [Airwallex API 文档](https://www.airwallex.com/docs/api#/Payment_Acceptance/Payment_Intents/)

``` swift
let paymentIntent = "The payment intent created on your server"
// 将 payment intent 和 session 绑定
session.paymentIntent = paymentIntent
```
---

#### 设置客户端密钥
- 对于**一次性支付**和**带 intent 的订阅支付**，使用 `paymentIntent` 中的 `clientSecret`
``` swift
AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
```

- 对于**订阅支付**，您需要使用 customer ID 在服务器端创建 **客户端密钥**并将其传递给 `AWXAPIClientConfiguration`。

相关接口信息，请参阅 [Airwallex API 文档](https://www.airwallex.com/docs/api#/Payment_Acceptance/Customers/_api_v1_pa_customers__id__generate_client_secret/get/)

``` swift
let clientSecret = "The client secret generated with customer ID on your server"
AWXAPIClientConfiguration.shared().clientSecret = clientSecret
```

### 可选设置
#### 微信支付
- 确保添加 `AirwallexWeChatpay`（Swift package manager）或 `Airwallex/WechatPay`（Cocoapods）的依赖
- 按照[微信官方集成文档](https://developers.weixin.qq.com/doc/oplatform/en/Mobile_App/Access_Guide/iOS.html)设置 `WechatOpenSDK`

``` swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WXApi.registerApp("WeChat app ID", universalLink: "universal link of your app")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
}

extension AppDelegate: WXApiDelegate {
    func onResp(_ resp: BaseResp) {
        if let response = resp as? PayResp {
            switch response.errCode {
                // handle payment result
            }
        }
    }
}
```
完成支付后，微信将调转回商户应用并回调到 `onResp()`函数。
微信 SDK 会在商户的服务端获取到获取到支付状态后更新对应 payment intent 的状态，所以请持续监听 `onResp()` 的回调
  
> [!NOTE]
> 我们使用基于 `WechatOpenSDK.xcframework` 2.0.4 版本重新构建的动态框架 `WechatOpenSDKDynamic.xcframework` 进行微信支付集成。
> 通过这样做，我们可以
> 1. 从 SPM 目标 `AirwallexWeChatPay` 中删除不安全的 linker flag `-ObjC`、`-all_load`
> 2. 删除现代应用程序不再需要的架构 `armv7` 和 `i386`。
>
---
#### Apple Pay

Airwallex iOS SDK 支持 Apple Pay 支付方式。 

- 请确保您的应用已正确设置 Apple Pay。
  - 具体步骤请参阅 Apple 的官方[文档](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay)。
- 确保您的 Airwallex 账户中已启用 Apple Pay。
- 集成 SDK 时包含 Apple Pay 模块 
  - `AirwallexWeChatpay` - Swift Package Manager
  - `Airwallex/ApplePay` - CocoaPods
- 准备[商户标识符](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay)并在支付会话对象上配置 `applePayOptions`。

``` swift
let session = AWXOneOffSession()
//  configure other properties
...
session.applePayOptions = AWXApplePayOptions(merchantIdentifier: "Your Merchant Identifier")// required for Apple Pay
```
您可以自定义 Apple Pay 选项以对支付方式做出限制并且提供额外的交易信息。全部可配置项信息请参阅 `AWXApplePayOptions.h` 头文件。
```swift
let options = AWXApplePayOptions(merchantIdentifier: applePayMerchantId)
options.additionalPaymentSummaryItems = [
    .init(label: "goods", amount: 10),
    .init(label: "tax", amount: 1)
]
options.merchantCapabilities = [.threeDSecure, .debit]
options.requiredBillingContactFields = [.postalAddress]
options.supportedCountries = ["AU"]
options.totalPriceLabel = "COMPANY, INC."
```

> [!IMPORTANT]
> 请注意，我们目前仅支持以下支付网络：
>- Visa
>- MasterCard
>- ChinaUnionPay
>- Maestro (iOS 12+)
>- Amex
>- Discover
>- JCB

>[!IMPORTANT]
> 目前不支持 Coupon


### UI 集成

#### 启动完整支付列表（推荐）
> [!NOTE]
> 它在您的应用程序中使用我们预构建的 UI 收集支付详情、账单详情并确认支付。

在结账时，使用 `AWXUIContext` 启动支付流程，用户能够通过支付列表选择您支持的支付方式。
``` swift
try AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    filterBy: "An optional array of payment method names used to filter the payment methods returned by the server"
)
```
---
#### 仅展示卡支付
```swift
try AWXUIContext.launchCardPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    supportedBrands: "accepted card brands, should not be empty"
)
```

> [!Tip]
> 如果您想仅展示卡支付并希望能够使用已保存的卡支付，可以启动完整支付列表并通过 `filterBy` 参数限制仅展示卡支付
``` swift
try AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    filterBy: [AWXCardKey]
)
```
---
#### 按名称启动支付方式
```swift
try AWXUIContext.launchPayment(
    name: "payment method name",
    from: "hosting view controller",
    session: "The session created above",
    paymentResultDelegate: "object handles AWXPaymentResultDelegate"
)
```
> [!TIP]
> 可用的支付方式名称可以在[Airwallex API 文档](https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get)中找到  

---
#### 自定义主题色

您可以自定义 Airwallex UI 的主题色。
``` swift
AWXTheme.shared().tintColor = .red
```

### Low-level API 集成

您可以向用户提供自定义UI，然后基于 Low-level API 向客户提供支付功能

> [!NOTE]
> 您仍然需要完成[必要设置](#必要设置)中列出的所有步骤。[UI 集成](#UI-集成)的部分将被 `PaymentSessionHandler` 和[Low-level API 集成](#Low-level-API-集成)替换
> 
> 如果您使用这种集成方式，您可能会需要使用[Airwallex API 文档](https://www.airwallex.com/docs/api#/Payment_Acceptance)来获取自定义UI需要的各种信息

---
#### 创建 PaymentSessionHandler 

```swift
let paymentSessionHandler = try PaymentSessionHandler(
    session: "The session created above", 
    viewController: "hosting view controller which also handles AWXPaymentResultDelegate"
)
self.paymentSessionHandler = paymentSessionHandler
```

> [!TIP]
> 初始化后，您需要将 `paymentSessionHandler` 存储在与视图生命周期绑定的视图控制器或类中

---
#### 使用卡支付
```swift
// Confirm intent with card and billing
try paymentSessionHandler.startCardPayment(
    with: "The AWXCard object collected by your custom UI",
    billing: "The AWXPlaceDetails object collected by your custom UI"
)
```
---
#### 使用保存的卡支

- 使用 `AWXPaymentConsent` 支付 
``` swift
try paymentSessionHandler.startConsentPayment(with: "payment consent")
```

- 使用 consent ID 支付 - 仅当保存的卡是**网络令牌**时使用这种支付方式
``` swift
try paymentSessionHandler.startConsentPayment(withId: "consent ID")
```

---
#### 使用 Apple Pay 支付
> [!IMPORTANT]
> 确保 `session.applePayOptions` 设置正确。
> 
> 详情请参阅[设置 Apple Pay](#Apple-Pay)部分对 apple pay 进行设置
> 
``` swift
try paymentSessionHandler.startApplePay()
```

---
#### 使用跳转支付
> [!IMPORTANT] 
> 您应在 `additionalInfo` 中提供 "/api/v1/pa/config/payment_method_types/${payment method name}" 中指定的所有必填字段
``` swift
try paymentSessionHandler.startRedirectPayment(
    with: "payment method name",
    additionalInfo: "all required information"
)
```

### 处理支付结果

在用户完成/取消支付后，您可以在 `AWXPaymentResultDelegate` 的回调中处理支付结果。
``` swift
func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: Error?) {
    // call back for status success/in progress/ failure / cancel
}
```

> [!TIP]
> 如果在支付过程中创建了 consent，您可以实现此可选函数以获取 consent ID 以供进一步使用。
```swift
func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
    // To do anything with this ID.
}
```

## 贡献

我们欢迎任何形式的贡献，包括新功能、错误修复和文档改进。最好的贡献方式是提交拉取请求——我们会尽快回复您的补丁。如果您发现错误或有任何问题，也可以提交问题。
