// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AirWallexPaymentSDK",
    platforms: [ .iOS(.v13) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Airwallex",
            targets: [
                "AirwallexCore",
                "AirwallexApplePay",
                "AirwallexCard",
                "AirwallexRedirect",
                "AirwallexWeChatpay"
            ]
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
            name: "AirwallexWeChatpay",
            targets: ["AirwallexWeChatpay"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/weiping-awx/airwallex-wechatpay-ios", branch: "main")
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
        .target(
            name: "AirwallexCore",
            dependencies: [ "AirwallexRisk", "AirTracker" ],
            path: "Airwallex/Core/Sources",
            exclude: [ "Empty.swift" ],
            resources: [ .process("../Resources/AirwallexCore.bundle/")],
            cSettings: [
                .headerSearchPath("Internal"),
                .headerSearchPath("Internal/Extensions")
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
            name: "AirwallexWeChatpay",
            dependencies: [
                "AirwallexCore",
                .product(name: "AirwallexWechatPayInternal", package: "airwallex-wechatpay-ios")
            ],
            path: "Airwallex/WeChatPay",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Internal")
            ]
        )
    ]
)
