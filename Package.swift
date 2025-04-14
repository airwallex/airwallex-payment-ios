// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Airwallex",
    platforms: [ .iOS(.v13) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Airwallex",
            targets: [ "Airwallex" ]
        ),
        .library(
            name: "AirwallexPaymentSheet",
            targets: [ "AirwallexPaymentSheet" ]
        ),
        .library(
            name: "AirwallexPayment",
            targets: [ "AirwallexPayment" ]
        ),
        .library(
            name: "AirwallexCore",
            targets: ["AirwallexCore"]
        ),
        .library(
            name: "AirwallexWeChatpay",
            targets: ["AirwallexWeChatpay"]
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
            name: "Airwallex",
            dependencies: [
                .target(name: "AirwallexPaymentSheet")
            ],
            path: "Airwallex/Airwallex",
            sources: [ "Airwallex_Export.swift" ]
        ),
        .target(
            name: "AirwallexPaymentSheet",
            dependencies: [
                .target(name: "AirwallexPayment")
            ],
            path: "Airwallex/AirwallexPaymentSheet",
            sources: [ "Sources" ],
            resources: [ .process("Resources")]
        ),
        .target(
            name: "AirwallexPayment",
            dependencies: [
                .target(name: "AirwallexCore")
            ],
            path: "Airwallex/AirwallexPayment",
            sources: [ "Sources" ],
            resources: [ .process("Resources")]
        ),
        .target(
            name: "AirwallexCore",
            dependencies: [ "AirwallexRisk", "AirTracker" ],
            path: "Airwallex/AirwallexCore",
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
            name: "AirwallexWeChatpay",
            dependencies: [
                "AirwallexCore",
                .target(name: "WechatOpenSDKDynamic")
            ],
            path: "Airwallex/AirwallexWeChatpay",
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
