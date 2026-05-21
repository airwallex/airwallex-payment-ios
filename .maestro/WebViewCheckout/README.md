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
flow_open_h5_webview.yaml             # reusable: cold-launch sample app → H5 demo → /shopping-cart
test_webview_checkout_renders.yaml    # P0: assert checkout-ui mounts + Pay button shows
test_webview_card_3ds_success.yaml    # P1: full card flow incl. 3DS challenge (test card 4012000300000088)
README.md                             # this file
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

# P0: WebView mount + Pay button
maestro test .maestro/WebViewCheckout/test_webview_checkout_renders.yaml

# P1: Full card flow incl. 3DS challenge (test card 4012000300000088, OTP 1234)
maestro --device "$(xcrun simctl list devices booted -j | python3 -c 'import json,sys; print(next(iter(json.load(sys.stdin)["devices"].values()))[0]["udid"])')" test .maestro/WebViewCheckout/test_webview_card_3ds_success.yaml
```

> **Status:** verified passing on `iPhone 16 / iOS 18.6` simulator with Xcode 16.4
> (May 2026).
>
> | Test | Time | Stability |
> |---|---|---|
> | `test_webview_checkout_renders.yaml` | ~70s | 1/1 green (incl. Apple Pay tap-level smoke) |
> | `test_webview_card_3ds_success.yaml` | ~69s | 2/2 green (test card `4012000300000088` Y-Y-SUCCESS, OTP `1234`) |
>
> See JIRA ACE-597 for the run screenshots.

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

## Iframe handling — iOS works, Android needs an adb workaround

Airwallex's card element renders card-number / expiry / CVC in nested
cross-origin iframes (`checkout.airwallex.com`). The two platforms behave
differently:

| | iOS `WKWebView` | Android `WebView` |
|---|---|---|
| Inner iframe inputs surfaced in a11y tree? | ✅ Yes (iOS 18+) | ✅ Yes |
| Maestro `tapOn { label: "Credit or debit card number" }` focuses PAN? | ✅ Yes | ⚠️ no native label, must use `point:` |
| Maestro `inputText: "401200..."` updates React state? | ✅ Yes | ❌ DOM updates but React `onChange` never fires |

That's why **iOS can be fully driven by Maestro**
(`test_webview_card_3ds_success.yaml`) while **Android drops to raw
`adb shell input` events** for everything iframe-internal — see the
[Android README](../../../airwallex-payment-android/.maestro/WebViewCheckout/README.md#iframe-limitation--the-adb-shell-input-workaround)
for the workaround's full design.

iOS-specific subtleties this test handles:

- The keyboard accessory bar's Done/Next buttons do NOT navigate iframe focus
  (sandboxed), so we use explicit coordinate taps between fields.
- Tapping `Pay 100.00 CNY` while the keyboard is up only dismisses the keyboard;
  a SECOND tap actually fires the click.
- The 3DS Challenge iframe is hosted on Cardinal Commerce (different origin
  from `checkout.airwallex.com`), so its text content is NOT exposed via
  WKWebView a11y. We use coordinate taps + `notVisible: "Cancel authentication"`
  as the "challenge finished" signal.

## Apple Pay sheet coverage

The P0 test asserts the Apple Pay button is **rendered + tappable + the
checkout-ui click handler runs without crashing WKWebView**. It does NOT
assert that the native `PKPaymentAuthorizationViewController` (Apple Pay
sheet) actually appears.

### Why the default sim build can't show the sheet

We tried during bring-up. The sequence verified on `iPhone 16 / iOS 18.6`:

1. `PaymentCoordinator::canMakePayments() -> 1` ✅ — WebKit confirms Apple
   Pay capability is on, JS gate passes.
2. checkout-ui calls `new PaymentRequest({ supportedNetworks: ["visa",...],
   merchantIdentifier: "merchant.demo.com.airwallex.paymentacceptance" })`.
3. PassKit refuses to present the sheet with
   `Error Domain=PKPassKitErrorDomain Code=4 "No entitlement for merchant
   identifier: (null)"`.

The root cause is that we built `Examples.app` with code signing disabled
(`CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""`), which strips
the `com.apple.developer.in-app-payments` entitlement from the binary.
Re-signing ad-hoc with `codesign -s - --entitlements
Examples.entitlements` puts the entitlement back, but iOS 18 Simulator's
AMFI rejects the launch (POSIX error 153) because `in-app-payments` is a
**restricted entitlement** that must be paired with an Apple Developer
provisioning profile bound to a real team that owns the listed merchant
IDs — and we don't have such a profile checked in.

### How to extend the test once a provisioned build exists

1. Sign `Examples.app` with the Airwallex team's provisioning profile that
   includes `merchant.demo.com.airwallex.paymentacceptance` (or any of the
   four merchant IDs already declared in `Examples.entitlements`).
2. Install to a simulator with a sandbox PassKit card added via
   `xcrun simctl spawn booted defaults write
   com.apple.PassKit.PaymentPassMaintenance LimitedNetworkInterval -int 0`
   followed by adding a test card through Settings → Wallet & Apple Pay.
3. Append after the Apple Pay tap step in
   `test_webview_checkout_renders.yaml`:

   ```yaml
   - tapOn: "Apple Pay"
   - extendedWaitUntil:
       visible: "Pay with Touch ID"   # PKPaymentAuthorizationViewController title
       timeout: 10000
   - takeScreenshot: apay_sheet_visible
   - tapOn: "Cancel"                  # Dismiss without committing
   ```

### Why we left this out of the merged regression

The provisioning profile + test card setup requires Apple Developer team
access we don't currently provision on CI runners, and the failure mode
that "sheet doesn't appear" would catch (PaymentRequest bridge broken in
WKWebView) is already caught at the tap level — if the bridge were
broken, the click handler would throw and our
`assertVisible: "Select payment method"` post-condition would fail.

When PA provisions an Apple Developer team for CI, this becomes a
one-PR follow-up.

## Future work / not blocking ACE-597

- Run on a booted iPhone 16 simulator in CI (`manual_first` per ticket scope).
- Apple Pay sheet appearance assertion (see above — requires team provisioning).
- Card-save + consent-reuse extension of `test_webview_card_3ds_success.yaml`
  (one extra render assertion + a second Pay using the saved card row).
