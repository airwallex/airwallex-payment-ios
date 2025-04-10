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
            targets: [ "AirwallexPayment", "AirwallexWeChatpay" ]
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
            name: "WechatOpenSDK",
            path: "Frameworks/WechatOpenSDK.xcframework"
        ),
        .target(
            name: "AirwallexPayment",
            dependencies: [
                .target(name: "AirwallexCore")
            ],
            path: "Airwallex/Payment",
            sources: [ "Sources" ],
            resources: [ .process("Resources")]
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
            name: "AirwallexWeChatpay",
            dependencies: [
                "AirwallexCore",
                "WechatOpenSDK"
            ],
            path: "Airwallex/WeChatPay",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Internal")
            ],
            linkerSettings: [
                .linkedLibrary("z"),        // Links libz (zlib)
                .linkedLibrary("sqlite3"),  // Links libsqlite3
                .linkedLibrary("c++"),       // Links libc++
                .unsafeFlags(["-ObjC", "-all_load"]),
            ]
        ),
        .testTarget(
            name: "AirwallexCoreTests",
            dependencies: [ "AirwallexCore" ]
        ),
    ]
)
