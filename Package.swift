// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AirwallexPaymentSDK",
    platforms: [ .iOS(.v13) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Airwallex",
            targets: [ "AirwallexCore", "AirwallexApplePay", "AirwallexCard", "AirwallexRedirect", "AirwallexWeChatPay" ]
        ),
        .library(
            name: "AirwallexCore",
            targets: ["AirwallexCore"]
        ),
        .library(
            name: "AirwallexApplePay",
            targets: ["AirwallexApplePay"]
        ),
        .library(
            name: "AirwallexCard",
            targets: ["AirwallexCard"]
        ),
        .library(
            name: "AirwallexRedirect",
            targets: ["AirwallexRedirect"]
        ),
        .library(
            name: "AirwallexWeChatPay",
            targets: ["AirwallexWeChatPay"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "AirwallexRisk",
            path: "Frameworks/AirwallexRisk.xcframework"
        ),
        .binaryTarget(
            name: "AirTracker",
            path: "Frameworks/AirTracker.xcframework"
        ),
        .binaryTarget(
            name: "WechatOpenSDKDynamic",
            path: "Frameworks/WechatOpenSDKDynamic.xcframework"
        ),
        .target(
            name: "AirwallexCore",
            dependencies: [ "AirwallexRisk", "AirTracker" ],
            path: "Airwallex/Core",
            exclude: [ "Sources/Empty.swift" ],
            sources: [ "Sources" ],
            resources: [ .process("Resources")],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/Internal"),
                .headerSearchPath("Sources/Internal/Extensions")
            ]
        ),
        .target(
            name: "AirwallexApplePay",
            dependencies: [ "AirwallexCore" ],
            path: "Airwallex/ApplePay",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Internal")
            ]
        ),
        .target(
            name: "AirwallexCard",
            dependencies: [ "AirwallexCore" ],
            path: "Airwallex/Card",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Internal")
            ]
        ),
        .target(
            name: "AirwallexRedirect",
            dependencies: [ "AirwallexCore" ],
            path: "Airwallex/Redirect",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Internal")
            ]
        ),
        .target(
            name: "AirwallexWeChatPay",
            dependencies: [
                "AirwallexCore",
                .target(name: "WechatOpenSDKDynamic")
            ],
            path: "Airwallex/WeChatPay",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Internal")
            ]
        ),
        .testTarget(
            name: "AirwallexCoreTests",
            dependencies: [ "AirwallexCore" ]
        ),
    ]
)
