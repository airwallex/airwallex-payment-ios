<!--
{
  "availability" : [

  ],
  "documentType" : "symbol",
  "framework" : "Airwallex",
  "identifier" : "/documentation/Airwallex/TermsOfUse/init(billingCycleChargeDay:endDate:firstPaymentAmount:fixedPaymentAmount:maxPaymentAmount:minPaymentAmount:paymentAmountType:paymentCurrency:paymentSchedule:startDate:totalBillingCycles:)",
  "metadataVersion" : "0.1.0",
  "role" : "Initializer",
  "symbol" : {
    "kind" : "Initializer",
    "modules" : [
      "Airwallex"
    ],
    "preciseIdentifier" : "c:@M@Airwallex@objc(cs)TermsOfUse(im)initWithBillingCycleChargeDay:endDate:firstPaymentAmount:fixedPaymentAmount:maxPaymentAmount:minPaymentAmount:paymentAmountType:paymentCurrency:paymentSchedule:startDate:totalBillingCycles:"
  },
  "title" : "init(billingCycleChargeDay:endDate:firstPaymentAmount:fixedPaymentAmount:maxPaymentAmount:minPaymentAmount:paymentAmountType:paymentCurrency:paymentSchedule:startDate:totalBillingCycles:)"
}
-->

# init(billingCycleChargeDay:endDate:firstPaymentAmount:fixedPaymentAmount:maxPaymentAmount:minPaymentAmount:paymentAmountType:paymentCurrency:paymentSchedule:startDate:totalBillingCycles:)

**Initializer**

Creates a new TermsOfUse instance to specify how Payment Consent will be used.

```
@objc init(billingCycleChargeDay: Int = 0, endDate: Date? = nil, firstPaymentAmount: NSDecimalNumber? = nil, fixedPaymentAmount: NSDecimalNumber? = nil, maxPaymentAmount: NSDecimalNumber? = nil, minPaymentAmount: NSDecimalNumber? = nil, paymentAmountType: PaymentAmountType, paymentCurrency: String? = nil, paymentSchedule: PaymentSchedule? = nil, startDate: Date? = nil, totalBillingCycles: Int = 0)
```

## Parameters

`billingCycleChargeDay`

The granularity per billing cycle. Required when payment_schedule.period_unit is WEEK, MONTH, or YEAR.
For example: charge_day_per_billing_cycle = 5, period_unit = MONTH, period = 1 means collect payment on the 5th of each month.
Default: 0 (will not be included in JSON encoding).

`endDate`

End date to expect payment request. The Date object will be converted to yyyy-MM-dd format during JSON encoding.
Default: nil.

`firstPaymentAmount`

The first payment amount. It could include the costs associated with the first debited amount.
Optional if payment agreement type is VARIABLE. Default: nil.

`fixedPaymentAmount`

The fixed payment amount that can be charged for a single payment.
Required if payment agreement type is FIXED. Default: nil.

`maxPaymentAmount`

The maximum payment amount that can be charged for a single payment.
Optional if payment agreement type is VARIABLE. Default: nil.

`minPaymentAmount`

The minimum payment amount that can be charged for a single payment.
Optional if payment agreement type is VARIABLE. Default: nil.

`paymentAmountType`

The agreed type of amounts for subsequent payment. Should be either .fixed or .variable.
- .fixed: Payment amount is fixed. A specific amount is required.
- .variable: Payment amount is variable at each collection. A max limit is recommended.

`paymentCurrency`

The currency of this payment. Please refer to supported currencies. Default: nil.

`paymentSchedule`

Payment schedule configuration specifying billing frequency and period.
Required if merchant_trigger_reason = scheduled. Default: nil.

`startDate`

Start date to expect payment request. The Date object will be converted to yyyy-MM-dd format during JSON encoding.
Default: nil.

`totalBillingCycles`

The total number of billing cycles. For example, the mandate will last for 1 year if totalBillingCycles=12,
payment_schedule.period=1 and payment_schedule.period_unit=MONTH when merchant_trigger_reason is scheduled.
Merchant can bill customers 12 times when totalBillingCycles=12 if merchant_trigger_reason is unscheduled.
The mandate will continue indefinitely if totalBillingCycles is 0 (default).
Default: 0 (will not be included in JSON encoding).
