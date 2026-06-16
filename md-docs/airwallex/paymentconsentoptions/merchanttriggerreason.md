<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/PaymentConsentOptions/merchantTriggerReason",
  "metadataVersion" : "0.1.0",
  "role" : "Instance Property",
  "symbol" : {
    "kind" : "Instance Property",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)PaymentConsentOptions(py)merchantTriggerReason"
  },
  "title" : "merchantTriggerReason"
}
-->

# merchantTriggerReason

**Instance Property**

indicate whether the subsequent payments are scheduled.
Only applicable when next_triggered_by is merchant. One of `.undefined`, `scheduled`, `unscheduled`, `installments`. Default: `.undefined`
Note: Automatically set to `.undefined` when nextTriggeredBy is `.customerType`

```
@objc let merchantTriggerReason: AirwallexMerchantTriggerReason
```
