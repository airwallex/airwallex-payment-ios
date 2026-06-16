<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/AWXSession/returnURL",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:objc(cs)AWXSession(py)returnURL"
  },
  "title" : "returnURL"
}
-->

# returnURL

**Instance Property**

Return URL for redirecting users back to your app after external payment processing.

```
var returnURL: String? { get set }
```

## Discussion

This URL is required when payments are processed outside of your app and users need to be redirected back.

URL Format Guidelines:

- Use universal links (recommended): https://example.com/
  - Required for wechatpay
- Custom URL schemes (fallback): yourapp://payment/return
- Must be registered in your app’s URL schemes or Associated Domains

Note:

- Universal links are strongly recommended over custom URL schemes for better user experience
- Can be nil if you only support in-app payment methods (Apple Pay, cards)
