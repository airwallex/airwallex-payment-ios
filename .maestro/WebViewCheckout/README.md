# Webview Checkout Regression (iOS)

iOS mirror of `airwallex-payment-android/.maestro/WebViewCheckout/`. Proves the
Airwallex **checkout-ui** mounts correctly inside the iOS SDK sample app's
`WebViewController` (`WKWebView`).

JIRA: [ACE-597](https://airwallex.atlassian.net/browse/ACE-597).

## What this suite does — and what it intentionally doesn't

See the [Android README](../../../airwallex-payment-android/.maestro/WebViewCheckout/README.md)
for the full design rationale. tl;dr: the suite verifies *WebView integration* (does
checkout-ui mount, are payment methods initialized, is the Pay button wired up with
a currency-formatted amount) and leaves *card / 3DS / digital wallet* end-to-end
behaviour to the FE Playwright suite, which already runs those scenarios under
`mobile-webkit`.

## Files

```
flow_open_h5_webview.yaml          # reusable: cold-launch sample app → H5 demo → /shopping-cart
test_webview_checkout_renders.yaml # P0: assert checkout-ui mounts + Pay button shows
README.md                          # this file
```

## Run

```bash
# Pre-reqs:
#   - Xcode 15+ with an iOS 17 simulator
#   - Maestro CLI (`curl -sLfO https://get.maestro.mobile.dev && bash maestro`)
#   - Sample app built and installed to a booted simulator
#       xcodebuild -workspace AirwallexRisk.xcworkspace \
#                  -scheme paymentacceptance \
#                  -destination 'platform=iOS Simulator,name=iPhone 15' \
#                  -derivedDataPath build
#       xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/paymentacceptance.app

export PATH="$HOME/.maestro/bin:$PATH"
xcrun simctl boot "iPhone 15" 2>/dev/null || true

maestro test .maestro/WebViewCheckout/test_webview_checkout_renders.yaml
```

> **Note:** the iOS half of this suite was authored alongside the Android half and
> validated for syntax (`maestro check-syntax`), but the actual run-on-simulator pass
> happened on Android only during initial bring-up. The next step is to install the
> iOS sample app to a simulator and confirm the same green result there — selectors
> are mirrored from the Android suite to use anchors that exist in the same
> checkout-ui markup, so we expect parity.

## iOS-specific differences vs Android

| Concern | Android | iOS |
|---|---|---|
| Sample app entry point label | `"Launch HTML5 Demo"` | `"Integrate with HTML5 DEMO"` |
| H5 demo screen title | `"Launch HTML 5 Demo"` | `"Launch HTML 5 demo"` (lowercase d) |
| WebView class | `android.webkit.WebView` (`H5WebViewActivity`) | `WKWebView` (`WebViewController`) |
| Cold launch | `launchApp { stopApp: true }` | same (kills via `springboard`) |
| URL field input bug | Gboard autocorrects URL → use AdbKeyBoard | UITextField autocorrect → disable via `xcrun simctl spawn booted defaults write -g KeyboardAutocorrection -bool NO` |
| Digital wallet button visibility | Google Pay reliably in a11y tree | Apple Pay reliably in a11y tree |
| Pay button label | `"Pay 100.00 CNY"` | same (checkout-ui i18n) |

## Iframe limitation

Same as Android: Airwallex's card element renders card-number / expiry / CVC in
nested cross-origin iframes (`checkout.airwallex.com`). iOS `WKWebView`'s
accessibility tree only surfaces the first iframe level, so Maestro cannot reach
those inner inputs by id, name, or placeholder. Coordinate taps work for a single
device but break under any layout change. See Android README for the long-form
explanation and the three options for unblocking full card-flow automation.

## Future work / not blocking ACE-597

- Run on a booted iPhone 15 simulator in CI (`manual_first` per ticket scope).
- Add an Apple Pay sheet smoke test that injects a test wallet via
  `PKPaymentRequest.fake(simulator: true)`.
