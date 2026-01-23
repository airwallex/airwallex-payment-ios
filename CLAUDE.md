# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Airwallex iOS SDK - A payment integration SDK for iOS apps supporting card payments, Apple Pay, WeChat Pay, and redirect-based payment methods.

## Build Commands

```bash
# Install dependencies (required after clone)
pod install

# Open workspace
open Airwallex.xcworkspace

# Build via command line
xcodebuild -workspace Airwallex.xcworkspace -scheme Examples -sdk iphonesimulator -configuration Debug build

# Run tests
xcodebuild test -workspace Airwallex.xcworkspace -scheme Airwallex -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Linting

SwiftLint is configured via `.swiftlint.yml`. A Claude Code hook automatically runs SwiftLint after editing Swift files.

```bash
# Run SwiftLint
swiftlint

# Auto-fix correctable issues
swiftlint --fix
```

Key disabled rules: `force_cast`, `force_try`, `xctfail_message` (common in tests)

## Architecture

### Module Hierarchy

```
Airwallex (umbrella)
    └── AirwallexPaymentSheet (UI components)
            └── AirwallexPayment (payment logic, providers)
                    └── AirwallexCore (networking, models, Obj-C APIs)

AirwallexWeChatPay (standalone, depends on AirwallexCore)
```

### Key Components

**AirwallexCore** (`Airwallex/AirwallexCore/Sources/`)
- Objective-C public APIs (`AWX*` prefixed classes)
- Network layer, models, card/ApplePay handling
- Binary frameworks: `AirwallexRisk.xcframework`, `AirTracker.xcframework`

**AirwallexPayment** (`Airwallex/AirwallexPayment/Sources/`)
- `PaymentSessionHandler` - Central class for low-level API integration
- `CardProvider`, `ApplePayProvider`, `RedirectProvider` - Payment method implementations
- `Session` - Unified payment session (replaces legacy `AWXOneOffSession`, `AWXRecurringSession`)

**AirwallexPaymentSheet** (`Airwallex/AirwallexPaymentSheet/Sources/`)
- `AWXUIContext` - Entry point for launching payment UI
- `PaymentSheet/` - Tab and accordion payment layouts
- `CollectionViewManager/` - Section-based UI architecture
- Section controllers: `CardPaymentConsentSectionController`, `SchemaPaymentSectionController`, etc.

### Distribution

- **Swift Package Manager**: `Package.swift`
- **CocoaPods**: `Airwallex.podspec`

### Examples App

Located in `Examples/`. Configure API keys in `Examples/Keys/Keys.json`.

## Swift Code Style

Before writing Swift code, read `.swiftlint.yml` and follow its rules.
