# Migration Guides
## Migrating from versions < 6.0.0

We have introduced a brand new UI for payments and a new set of APIs to launch payments.
### UI Integration

<img src="https://github.com/user-attachments/assets/babf2af3-d59b-49fc-8b86-26e85df28a0c" width="200" hspace="10">

The Objective-C APIs have been completely removed. Use the API in `AWXUIContext+Extensions.swift` to launch Airwallex Payment UI instead


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
// Launch Payment Method by Name
AWXUIContext.launchPayment(
    name: "payment method name",
    from: "hosting view controller",
    session: "The session created above",
    paymentResultDelegate: "object that handles AWXPaymentResultDelegate",
    style: "present or push"
)
```
>[!TIP]
These new APIs update `session` and `delegate` on `AWXUIContext` in their implementation, so you don't need to explicitly update `session` and `delegate` on `AWXUIContext` anymore.

### Low-level API Integration
Replace providers with `PaymentSessionHandler`.

You no longer need to interact with providers like `AWXCardProvider` or `AWXApplePayProvider`, which introduced unnecessary complexity and required you to handle `AWXProviderDelegate`, which mainly for internal usage.

> [!NOTE] 
> With `PaymentSessionHandler` you can handle the payment result using `AWXPaymentResultDelegate` just like UI Integration.

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