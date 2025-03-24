# Migration Guides
## Migrating from versions < 6.0.0

We have introduced a brand new UI for payments and a new set of APIs to launch payments.
### UI Integration

<img src="https://github.com/user-attachments/assets/babf2af3-d59b-49fc-8b86-26e85df28a0c" width="200" hspace="10">

Use the API in `AWXUIContext+Extensions.swift` to launch Airwallex Payment UI instead

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
#### New:
``` swift
//  Launch Payment Sheet
AWXUIContext.launchPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    filterBy: "An optional array of payment method names used to filter the payment methods returned by the server",
    style: "present or push"
)
// Launch Card Payment Directly
AWXUIContext.launchCardPayment(
    from: "hosting view controller which also handles AWXPaymentResultDelegate",
    session: "The session created above",
    supportedBrands: "accepted card brands, should not be empty",
    style: "present or push"
)
```
>[!TIP]
You don't need to explicitly set `session` and `delegate` on `AWXUIContext` before you call `AWXUIContext.launchPayment`. 

### Low-level API Integration
Replace providers with `PaymentSessionHandler`.

You no longer need to interact with providers like `AWXCardProvider` or `AWXApplePayProvider`, which introduced unnecessary complexity and required you to handle `AWXProviderDelegate`, which is mainly for internal usage.

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
#### New:
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
> [!NOTE] 
> With `PaymentSessionHandler` you can handle the payment result using `AWXPaymentResultDelegate` just like UI Integration.
