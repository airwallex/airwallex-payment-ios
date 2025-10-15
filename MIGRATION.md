# Migration Guides
## Migrating from versions < 6.0.0

### Dependency optimization
- Separation of Integrations:
  - UI Integration and Low-level Integration are now separated. You can add minimum dependency for Low-level Integration by adding `AirwallexPayment` only.
- WeChat Pay Support:
  - WeChat Pay is not supported by default because it requires embedding a third-party framework (`WeChatOpenSDK`). To enable WeChat Pay, you must explicitly add dependency for `AirwallexWeChatPay`.
- Consistent Naming:
  - Module/Subspec names are now consistent across both Swift Package Manager (SPM) and CocoaPods.

#### Dependency Graph - New:
```
Airwallex
└── AirwallexPaymentSheet
    └── AirwallexPayment
        └── AirwallexCore
            ├── AirwallexRisk (binary target)
            └── AirTracker (binary target)

AirwallexWeChatPay
│── AirwallexCore
│    ├── AirwallexRisk (binary target)
│    └── AirTracker (binary target)
└── WechatOpenSDKDynamic (binary target)
```
#### Dependency Graph - Old:
- Swift Package manager:
```
Airwallex
├── AirwallexCore
│   ├── AirwallexRisk (binary target)
│   └── AirTracker (binary target)
├── AirwallexApplePay
│   └── AirwallexCore
├── AirwallexCard
│   └── AirwallexCore
├── AirwallexRedirect
│   └── AirwallexCore
└── AirwallexWeChatPay
    ├── AirwallexCore
    │   ├── AirwallexRisk (binary target)
    │   └── AirTracker (binary target)
    └── WechatOpenSDKDynamic (binary target)
```
- CocoaPods:
```
Airwallex
├── Core
│   ├── AirTracker.xcframework (vendored framework)
│   └── AirwallexRisk.xcframework (vendored framework)
├── WeChatPay
│   ├── Core
│   └── WechatOpenSDKDynamic.xcframework (vendored framework)
├── Card
│   └── Core
├── Redirect
│   └── Core
└── ApplePay
    └── Core
```
For more details please refer to [README - Integration](README.md#integration)
### UI Integration
Use the API in `AWXUIContext` to launch Airwallex Payment Sheet

#### New:
``` swift
//  Launch Payment Sheet
AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    filterBy: "An optional array of payment method names used to filter the payment methods returned by the server",
    launchStyle: "present or push",
    layout: "tab/accordion"
)
// Launch Card Payment Directly
AWXUIContext.launchCardPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    supportedBrands: "accepted card brands, should not be empty",
    launchStyle: "present or push"
)
```
>[!TIP]
> Now you don't need to explicitly set `session` and `delegate` on `AWXUIContext` before you call `AWXUIContext.launchPayment(...)`. 

#### Old:
``` objc
AWXUIContext *context = [AWXUIContext sharedContext];
context.delegate = "The target to handle AWXPaymentResultDelegate protocol";
context.session = "The session created above";
//  Launch Payment Sheet
[context presentEntirePaymentFlowFrom:self];
// Launch Card Payment Directly
[context presentCardPaymentFlowFrom:self cardSchemes:["available card schemes"]];
```

### Low-level API Integration
Replace providers with `PaymentSessionHandler`.

You no longer need to interact with providers like `AWXCardProvider` or `AWXApplePayProvider`, which introduced unnecessary complexity and required you to handle `AWXProviderDelegate`, which is mainly for internal usage.

#### New:
> [!NOTE] 
> Low-level API integration now supports payment status callbacks using `AWXPaymentResultDelegate`, just like the UI integration.
> 
```swift
let paymentSessionHandler = PaymentSessionHandler(
    session: "The session created above", 
    viewController: "hosting view controller which also handles AWXPaymentResultDelegate"
)
self.paymentSessionHandler = paymentSessionHandler
```
```swift
// Pay with Card
paymentSessionHandler.startCardPayment(
    with: "The AWXCard object collected by your custom UI",
    billing: "The AWXPlaceDetails object collected by your custom UI"
)

// Pay with consent object
paymentSessionHandler.startConsentPayment(with: "payment consent")

// Pay with consent ID
paymentSessionHandler.startConsentPayment(withId: "consent ID")

// Pay with Apple Pay
paymentSessionHandler.startApplePay()

// Pay with Redirect
paymentSessionHandler.startRedirectPayment(
    with: "payment method name",
    additionalInfo: "all required information"
)
```

#### Old:
```objc
AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:"The target to handle AWXProviderDelegate protocol" session:"The session created above"];
// After initialization, you will need to store the provider in your view controller or class that is tied to your view's lifecycle
self.provider = provider;

// Confirm intent with card and billing
[provider confirmPaymentIntentWithCard:"The AWXCard object collected by your custom UI" billing:"The AWXPlaceDetails object collected by your custom UI" saveCard:"Whether you want the card to be saved as payment consent for future payments"];

// Confirm intent with a payment consent object (AWXPaymentConsent)
[provider confirmPaymentIntentWithPaymentConsent:paymentConsent];

// Confirm intent with a valid payment consent ID only when the saved card is **network token**
[provider confirmPaymentIntentWithPaymentConsentId:@"cst_xxxxxxxxxx"];
```

