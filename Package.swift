// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AirWallexPaymentSDK",
    platforms: [ .iOS(.v13) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AirwallexCore",
            targets: ["AirwallexCore"]
        ),
//        .library(
//            name: "AirwallexApplePay",
//            targets: ["AirwallexApplePay"]
//        )
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
//        .target(
//            name: "AirwallexApplePay",
//            dependencies: [ "AirwallexCore" ],
//            path: "Airwallex/ApplePay",
//            publicHeadersPath: "",
//            cSettings: [
//                .headerSearchPath("Internal")
//            ]
//        )
    ]
)
