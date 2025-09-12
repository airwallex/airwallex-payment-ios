# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Codebase Overview

This is the **Airwallex iOS SDK**, a payment processing framework that supports multiple payment methods including cards, Apple Pay, and WeChat Pay. The project is distributed as both Swift Package Manager package and CocoaPods pod.

### Architecture

The SDK follows a modular architecture with clear separation of concerns:

- **AirwallexCore**: Foundation layer containing networking, models, Apple Pay support, and utility classes
- **AirwallexPayment**: Low-level API integration layer for custom payment flows  
- **AirwallexPaymentSheet**: High-level UI components providing pre-built payment flows
- **AirwallexWeChatPay**: WeChat Pay integration (optional)
- **Airwallex**: Meta-package that includes everything except WeChat Pay

### Key Components

- **Payment Sessions**: `AWXOneOffSession`, `AWXRecurringSession`, `AWXRecurringWithIntentSession` for different payment flows
- **Payment Providers**: `AWXCardProvider`, `AWXApplePayProvider` for specific payment methods
- **UI Integration**: `AWXUIContext` for launching pre-built payment flows
- **Models**: `AWXPaymentIntent`, `AWXCard`, `AWXPaymentConsent`, etc.

### Binary Dependencies

The project includes several precompiled frameworks:
- `AirwallexRisk.xcframework` - Risk management
- `AirTracker.xcframework` - Analytics tracking  
- `WechatOpenSDKDynamic.xcframework` - WeChat Pay integration

## Development Commands

### Building and Testing

**Install Dependencies:**
```bash
pod install
```

**Build Project:**
```bash
# Open workspace in Xcode
open Airwallex.xcworkspace

# Command line build (if needed)
xcodebuild -workspace Airwallex.xcworkspace -scheme Airwallex -destination 'platform=iOS Simulator,name=iPhone 15' build
```

**Run Tests:**
```bash
# Run all tests using the test plan
xcodebuild test -workspace Airwallex.xcworkspace -scheme Airwallex -testPlan Airwallex -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -workspace Airwallex.xcworkspace -scheme AirwallexCoreTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Build Example App:**
```bash
# Make sure to update Examples/Keys/Keys.json with proper API keys if needed
xcodebuild -workspace Airwallex.xcworkspace -scheme Examples -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Code Structure

**Source Code Locations:**
- Core functionality: `Airwallex/AirwallexCore/Sources/`
- Payment API: `Airwallex/AirwallexPayment/Sources/`  
- UI Components: `Airwallex/AirwallexPaymentSheet/Sources/`
- WeChat Pay: `Airwallex/AirwallexWeChatPay/`
- Tests: Test targets in `Airwallex.xcodeproj`
- Examples: `Examples/` directory

**Key Patterns:**
- Objective-C and Swift mixed codebase
- Protocol-based design for payment providers
- Delegate pattern for payment result handling
- Resource bundles for localization and assets

### Integration Approaches

The SDK supports three integration styles:
1. **UI Integration** - Use `AWXUIContext.launchPayment()` for complete pre-built flows
2. **Low-level API** - Use `PaymentSessionHandler` with custom UI
3. **Direct Payment Methods** - Launch specific payment methods directly

### Testing

Test targets include:
- `AirwallexCoreTests` - Core functionality tests
- `AirwallexPaymentTests` - Payment API tests  
- `AirwallexPaymentSheetTests` - UI component tests

### Localization

The SDK supports 11 languages with string files in `AirwallexCore/Resources/` for:
English, Chinese (Simplified/Traditional), French, German, Japanese, Korean, Portuguese (PT/BR), Russian, Spanish, Thai

### Version Management

- Version is managed in `Airwallex.podspec` and `Package.swift`
- Automated version updates via `.github/scripts/update-versions.sh`
- Semantic release workflow for automated releases